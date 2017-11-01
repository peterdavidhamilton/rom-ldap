require 'dry/core/class_attributes'


require_relative 'class_methods'
require_relative 'default_socket'

module ROM
  module LDAP
    class Connection
      extend Dry::Core::ClassAttributes
      extend ClassMethods
      extend Initializer

      defines :default_connect_timeout
      defines :ldap_version
      defines :max_sasl_challenges


      default_connect_timeout 5
      ldap_version 3
      max_sasl_challenges 10


      ResponseMissingOrInvalidError = Class.new(StandardError)


      DELETE_REQUEST = Net::LDAP::PDU::DeleteRequest.freeze
      MODIFY_REQUEST = Net::LDAP::PDU::ModifyRequest.freeze

      INVALID_SEARCH = OpenStruct.new(
        status:      :failure,
        result_code: LDAP::ResultCode::OperationsError,
        message:    'Invalid search'
      ).freeze



      param :server, default: proc { {} }

      option :socket_class, default: proc { server.fetch(:socket_class, ::DefaultSocket) }

      attr_writer :socket_class

      def initialize(*)
        yield self if block_given?
      end




      def prepare_socket(server, timeout=nil)
        socket     = server[:socket]
        encryption = server[:encryption]

        @conn = socket
        setup_encryption(encryption, timeout) if encryption
      end



      def open_connection(server)
        hosts       = server[:hosts]
        encryption  = server[:encryption]
        timeout     = server[:connect_timeout] || self.class.default_connect_timeout

        socket_opts = { connect_timeout: timeout }

        errors = []

        hosts.each do |host, port|
          begin
            prepare_socket(server.merge(socket: @socket_class.new(host, port, socket_opts)), timeout)
            if encryption
              if encryption[:tls_options] &&
                 encryption[:tls_options][:verify_mode] &&
                 encryption[:tls_options][:verify_mode] == OpenSSL::SSL::VERIFY_NONE
                warn "not verifying SSL hostname of LDAPS server '#{host}:#{port}'"
              else
                @conn.post_connection_check(host)
              end
            end
            return
          rescue Net::LDAP::Error, SocketError, SystemCallError,
                 OpenSSL::SSL::SSLError => e
            # Ensure the connection is closed in the event a setup failure.
            close
            errors << [e, host, port]
          end
        end

        raise Net::LDAP::ConnectionError.new(errors)
      end







      def setup_encryption(args, timeout=nil)
        args[:tls_options] ||= {}
        case args[:method]
        when :simple_tls
          @conn = self.class.wrap_with_ssl(@conn, args[:tls_options], timeout)
          # additional branches requiring server validation and peer certs, etc.
          # go here.
        when :start_tls
          message_id = next_msgid
          request    = [
            Net::LDAP::StartTlsOid.to_ber_contextspecific(0),
          ].to_ber_appsequence(Net::LDAP::PDU::ExtendedRequest)

          write(request, nil, message_id)
          pdu = queued_read(message_id)

          if pdu.nil? || pdu.app_tag != Net::LDAP::PDU::ExtendedResponse
            raise Net::LDAP::NoStartTLSResultError, "no start_tls result"
          end

          raise Net::LDAP::StartTLSError,
                "start_tls failed: #{pdu.result_code}" unless pdu.result_code.zero?
          @conn = self.class.wrap_with_ssl(@conn, args[:tls_options], timeout)
        else
          raise Net::LDAP::EncMethodUnsupportedError, "unsupported encryption method #{args[:method]}"
        end
      end




      def close
        return if @conn.nil?
        @conn.close
        @conn = nil
      end




      def queued_read(message_id)
        if pdu = message_queue[message_id].shift
          return pdu
        end

        # read messages until we have a match for the given message_id
        while pdu = read
          return pdu if pdu.message_id == message_id

          message_queue[pdu.message_id].push pdu
          next
        end

        pdu
      end





      def message_queue
        @message_queue ||= Hash.new { |hash, key| hash[key] = [] }
      end


      def next_msgid
        @msgid ||= 0
        @msgid += 1
      end



      def read(syntax = Net::LDAP::AsnSyntax)
        return unless ber_object = socket.read_ber(syntax)

        Net::LDAP::PDU.new(ber_object)
      end



      def write(request, controls = nil, message_id = next_msgid)
        packet = [message_id.to_ber, request, controls].compact.to_ber_sequence
        socket.write(packet)
      end






      def bind(auth)
        meth = auth[:method]
        adapter = Net::LDAP::AuthAdapter[meth]
        adapter.new(self).bind(auth)
      end




      def encode_sort_controls(sort_definitions)
        return sort_definitions unless sort_definitions

        sort_control_values = sort_definitions.map do |control|
          control = Array(control) # if there is only an attribute name as a string then infer the orderinrule and reverseorder
          control[0] = String(control[0]).to_ber,
          control[1] = String(control[1]).to_ber,
          control[2] = (control[2] == true).to_ber
          control.to_ber_sequence
        end
        sort_control = [
          Net::LDAP::LDAPControls::SORT_REQUEST.to_ber,
          false.to_ber,
          sort_control_values.to_ber_sequence.to_s.to_ber,
        ].to_ber_sequence
      end





      def search(args = nil)
        args ||= {}

        filter = args[:filter] || Net::LDAP::Filter.eq("objectClass", "*")
        base   = args[:base]
        scope  = args[:scope] || Net::LDAP::SearchScope_WholeSubtree


        attrs  = Array(args[:attributes])
        attrs_only = args[:attributes_only] == true

        refs   = args[:return_referrals] == true
        deref  = args[:deref] || Net::LDAP::DerefAliases_Never


        size   = args[:size].to_i
        time   = args[:time].to_i
        paged  = args[:paged_searches_supported]
        sort   = args.fetch(:sort_controls, false)


        # raise ArgumentError, "search base is required" unless base
        # raise ArgumentError, "invalid search-size" unless size >= 0
        # raise ArgumentError, "invalid search scope" unless Net::LDAP::SearchScopes.include?(scope)
        # raise ArgumentError, "invalid alias dereferencing value" unless Net::LDAP::DerefAliasesArray.include?(deref)


        filter    = Net::LDAP::Filter.construct(filter) if filter.is_a?(String)
        ber_attrs = attrs.map { |attr| attr.to_s.to_ber }
        ber_sort  = encode_sort_controls(sort)


        rfc2696_cookie = [126, ""]
        result_pdu = nil
        n_results = 0

        message_id = next_msgid


        loop do
          # should collect this into a private helper to clarify the structure
          query_limit = 0
          if size > 0
            query_limit = if paged
                            (((size - n_results) < 126) ? (size - n_results) : 0)
                          else
                            size
                          end
          end

          request = [
            base.to_ber,
            scope.to_ber_enumerated,
            deref.to_ber_enumerated,
            query_limit.to_ber, # size limit
            time.to_ber,
            attrs_only.to_ber,
            filter.to_ber,
            ber_attrs.to_ber_sequence,
          ].to_ber_appsequence(Net::LDAP::PDU::SearchRequest)


          controls = []
          controls <<
            [
              Net::LDAP::LDAPControls::PAGED_RESULTS.to_ber,
              false.to_ber,
              rfc2696_cookie.map(&:to_ber).to_ber_sequence.to_s.to_ber,
            ].to_ber_sequence if paged

          controls << ber_sort if ber_sort
          controls = controls.empty? ? nil : controls.to_ber_contextspecific(0)

          write(request, controls, message_id)

          result_pdu = nil
          controls = []

          while pdu = queued_read(message_id)
            case pdu.app_tag
            when Net::LDAP::PDU::SearchReturnedData
              n_results += 1
              yield pdu.search_entry if block_given?
            when Net::LDAP::PDU::SearchResultReferral
              if refs
                if block_given?
                  se = Net::LDAP::Entry.new
                  se[:search_referrals] = (pdu.search_referrals || [])
                  yield se
                end
              end
            when Net::LDAP::PDU::SearchResult
              result_pdu = pdu
              controls = pdu.result_controls
              if refs && pdu.result_code == Net::LDAP::ResultCodeReferral
                if block_given?
                  se = Net::LDAP::Entry.new
                  se[:search_referrals] = (pdu.search_referrals || [])
                  yield se
                end
              end
              break
            else
              raise Net::LDAP::ResponseTypeInvalidError, "invalid response-type in search: #{pdu.app_tag}"
            end
          end



          more_pages = false

          if result_pdu.result_code == Net::LDAP::ResultCodeSuccess and controls
            controls.each do |c|
              if c.oid == Net::LDAP::LDAPControls::PAGED_RESULTS
                # just in case some bogus server sends us more than 1 of these.
                more_pages = false
                if c.value and c.value.length > 0
                  cookie = c.value.read_ber[1]
                  if cookie and cookie.length > 0
                    rfc2696_cookie[1] = cookie
                    more_pages = true
                  end
                end
              end
            end
          end

          break unless more_pages
        end # loop

        result_pdu || INVALID_SEARCH
      ensure
        messages = message_queue.delete(message_id)
      end






      def modify(dn:, message_id: next_msgid, operations: nil)

        ops = self.class.modify_ops(operations)

        request    = [
          dn.to_ber,
          ops.to_ber_sequence,

        ].to_ber_appsequence(MODIFY_REQUEST)

        write(request, nil, message_id)
        pdu = queued_read(message_id)

        if !pdu || pdu.app_tag != Net::LDAP::PDU::ModifyResponse
          raise "response missing or invalid"
        end

        pdu
      end





      def password_modify(args)
        dn = args[:dn]
        raise ArgumentError, 'DN is required' if !dn || dn.empty?

        ext_seq = [Net::LDAP::PasswdModifyOid.to_ber_contextspecific(0)]

        unless args[:old_password].nil?
          pwd_seq = [args[:old_password].to_ber(0x81)]
          pwd_seq << args[:new_password].to_ber(0x82) unless args[:new_password].nil?
          ext_seq << pwd_seq.to_ber_sequence.to_ber(0x81)
        end

        request = ext_seq.to_ber_appsequence(Net::LDAP::PDU::ExtendedRequest)

        message_id = next_msgid

        write(request, nil, message_id)
        pdu = queued_read(message_id)

        if !pdu || pdu.app_tag != Net::LDAP::PDU::ExtendedResponse
          raise Net::LDAP::ResponseMissingError, "response missing or invalid"
        end

        pdu
      end






      def add(args)
        add_dn = args[:dn] or raise Net::LDAP::EmptyDNError, "Unable to add empty DN"
        add_attrs = []
        a = args[:attributes] and a.each do |k, v|
          add_attrs << [k.to_s.to_ber, Array(v).map(&:to_ber).to_ber_set].to_ber_sequence
        end

        message_id = next_msgid
        request    = [add_dn.to_ber, add_attrs.to_ber_sequence].to_ber_appsequence(Net::LDAP::PDU::AddRequest)

        write(request, nil, message_id)
        pdu = queued_read(message_id)

                if !pdu || pdu.app_tag != Net::LDAP::PDU::AddResponse
                  raise ResponseMissingOrInvalidError, "response missing or invalid"
                end

        pdu
      end




      def rename(old_dn:, new_rdn:, delete_attrs: false, new_superior: nil, message_id: next_msgid)

        request = [
          old_dn.to_ber,
          new_rdn.to_ber,
          delete_attrs.to_ber
        ]

        if new_superior
          request << new_superior.to_ber_contextspecific(0)
        end

        write(request.to_ber_appsequence(MODIFY_RDN_REQUEST), nil, message_id)

        pdu = queued_read(message_id)

              if !pdu || pdu.app_tag != Net::LDAP::PDU::ModifyRDNResponse
                raise ResponseMissingOrInvalidError.new "response missing or invalid"
              end

        pdu
      end




      def delete(dn:, control_codes: nil, message_id: next_msgid)

        controls = control_codes.to_ber_control if control_codes

        request  = dn.to_s.to_ber_application_string(DELETE_REQUEST)

        write(request, controls, message_id)

        pdu = queued_read(message_id)

              if !pdu || pdu.app_tag != Net::LDAP::PDU::DeleteResponse
                raise ResponseMissingOrInvalidError, "response missing or invalid"
              end

        pdu
      end





      def socket
        return @conn if defined? @conn

        # First refactoring uses the existing methods open_connection and
        # prepare_socket to set @conn. Next cleanup would centralize connection
        # handling here.
        if @server[:socket]
          prepare_socket(@server)
        else
          @server[:hosts] = [[@server[:host], @server[:port]]] if @server[:hosts].nil?
          open_connection(@server)
        end

        @conn
      end

    end # class Connection


end
