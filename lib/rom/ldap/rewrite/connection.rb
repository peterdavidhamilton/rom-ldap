require 'dry/core/class_attributes'

require_relative 'class_methods'
require_relative 'default_socket'

module ROM
  module LDAP
    class Connection
      extend Dry::Core::ClassAttributes
      extend ClassMethods
      extend Initializer

      defines :connect_timeout
      defines :ldap_version
      defines :max_sasl_challenges

      connect_timeout 5
      ldap_version 3
      max_sasl_challenges 10

      ResponseMissingOrInvalidError = Class.new(StandardError)

      DELETE_REQUEST = Net::LDAP::PDU::DeleteRequest
      MODIFY_REQUEST = Net::LDAP::PDU::ModifyRequest

      INVALID_SEARCH = OpenStruct.new(
        status:      :failure,
        result_code: ROM::LDAP::ResultCode::OperationsError,
        message:    'Invalid search'
      ).freeze


      option :host,            default: proc { '127.0.0.1' }
      option :port,            default: proc { 10389 }
      option :hosts,           default: proc { [[host, port]] }
      option :encryption,      default: proc { nil }
      option :connect_timeout, default: proc { self.class.connect_timeout }
      option :socket_class,    default: proc { ::DefaultSocket }
      option :socket,          optional: true

      attr_writer :socket_class

      def initialize(*)
        yield self if block_given?
      end


      def open_connection
        errors = []

        hosts.each do |host, port|
          begin

            @conn = socket_class.new(host, port, { connect_timeout: timeout })

            setup_encryption(encryption, timeout) if encryption

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

          rescue  Net::LDAP::Error,
                  SocketError, SystemCallError,
                  OpenSSL::SSL::SSLError => e

            close
            errors << [e, host, port]
          end
        end

        raise Net::LDAP::ConnectionError, errors
      end


      def socket
        return @conn if defined?(@conn)

        if socket
          @conn = socket
          setup_encryption(encryption, timeout) if encryption
        else
          open_connection(@server)
        end

        @conn
      end


      def setup_encryption(tls_options: {}, method:, timeout: nil, message_id: next_msgid)

        case method
        when :simple_tls

          @conn = self.class.wrap_with_ssl(@conn, tls_options, timeout)

        when :start_tls

          request = [
            START_TLS.to_ber_contextspecific(0)
          ].to_ber_appsequence(Net::LDAP::PDU::ExtendedRequest)

          write(request, nil, message_id)

          pdu = queued_read(message_id)

          if pdu.nil? || pdu.app_tag != Net::LDAP::PDU::ExtendedResponse
            raise Net::LDAP::NoStartTLSResultError, 'no start_tls result'
          end

          unless pdu.result_code.zero?
            raise Net::LDAP::StartTLSError,
                  "start_tls failed: #{pdu.result_code}"
          end

          @conn = self.class.wrap_with_ssl(@conn, tls_options, timeout)

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

      def bind(method:)
        adapter = Net::LDAP::AuthAdapter[method]
        adapter.new(self).bind(auth) # FIXME: where was auth?
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
          SORT_REQUEST.to_ber,
          false.to_ber,
          sort_control_values.to_ber_sequence.to_s.to_ber
        ].to_ber_sequence
      end

      def search(
        base:,
        size:,
        filter: Net::LDAP::Filter.eq('objectClass', '*'),
        scope: SCOPE_SUBTREE,
        attributes: nil,
        attributes_only: false,
        return_referrals: false,
        deref: DEREF_NEVER,
        time: nil,
        paged_searches_supported: nil,
        sort_controls: false
      )

        attrs      = Array(attributes)
        attrs_only = attributes_only
        refs       = return_referrals

        size   = size.to_i
        time   = time.to_i
        paged  = paged_searches_supported
        sort   = sort_controls

        # raise ArgumentError, "search base is required" unless base
        # raise ArgumentError, "invalid search-size" unless size >= 0
        # raise ArgumentError, "invalid search scope" unless Net::LDAP::SearchScopes.include?(scope)
        # raise ArgumentError, "invalid alias dereferencing value" unless Net::LDAP::DerefAliasesArray.include?(deref)

        filter    = Net::LDAP::Filter.construct(filter) if filter.is_a?(String)
        ber_attrs = attrs.map { |attr| attr.to_s.to_ber }
        ber_sort  = encode_sort_controls(sort)

        rfc2696_cookie = [126, '']
        result_pdu     = nil
        n_results      = 0

        message_id = next_msgid

        loop do
          # should collect this into a private helper to clarify the structure
          query_limit = 0
          if size > 0
            query_limit = if paged
                            ((size - n_results) < 126 ? (size - n_results) : 0)
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
            ber_attrs.to_ber_sequence
          ].to_ber_appsequence(Net::LDAP::PDU::SearchRequest)

          controls = []
          if paged
            controls <<
              [
                Net::LDAP::LDAPControls::PAGED_RESULTS.to_ber,
                false.to_ber,
                rfc2696_cookie.map(&:to_ber).to_ber_sequence.to_s.to_ber
              ].to_ber_sequence
          end

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

          if (result_pdu.result_code == Net::LDAP::ResultCodeSuccess) && controls
            controls.each do |c|
              next unless c.oid == PAGED_RESULTS

              more_pages = false
              next unless c.value && !c.value.empty?
              cookie = c.value.read_ber[1]
              if cookie && !cookie.empty?
                rfc2696_cookie[1] = cookie
                more_pages = true
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

        request = [
          dn.to_ber,
          ops.to_ber_sequence
        ].to_ber_appsequence(MODIFY_REQUEST)

        write(request, nil, message_id)
        pdu = queued_read(message_id)

        if !pdu || pdu.app_tag != Net::LDAP::PDU::ModifyResponse
          raise 'response missing or invalid'
        end

        pdu
      end

      def password_modify(dn:, old_password: nil, new_password: nil, message_id: next_msgid)
        ext_seq = [PASSWORD_MODIFY.to_ber_contextspecific(0)]

        unless old_password.nil?
          pwd_seq = [old_password.to_ber(0x81)]
          pwd_seq << new_password.to_ber(0x82) unless new_password.nil?
          ext_seq << pwd_seq.to_ber_sequence.to_ber(0x81)
        end

        request = ext_seq.to_ber_appsequence(Net::LDAP::PDU::ExtendedRequest)

        write(request, nil, message_id)

        pdu = queued_read(message_id)

        if !pdu || pdu.app_tag != Net::LDAP::PDU::ExtendedResponse
          raise Net::LDAP::ResponseMissingError, 'response missing or invalid'
        end

        pdu
      end

      def add(dn:, attributes: EMPTY_ARRAY, message_id: next_msgid)
        add_attrs = []

        (a = attributes) && a.each do |k, v|
          add_attrs << [k.to_s.to_ber, Array(v).map(&:to_ber).to_ber_set].to_ber_sequence
        end

        request = [
          dn.to_ber,
          add_attrs.to_ber_sequence
        ].to_ber_appsequence(Net::LDAP::PDU::AddRequest)

        write(request, nil, message_id)

        pdu = queued_read(message_id)

        if !pdu || pdu.app_tag != Net::LDAP::PDU::AddResponse
          raise ResponseMissingOrInvalidError, 'response missing or invalid'
        end

        pdu
      end

      def rename(old_dn:, new_rdn:, delete_attrs: false, new_superior: nil, message_id: next_msgid)
        request = [
          old_dn.to_ber,
          new_rdn.to_ber,
          delete_attrs.to_ber
        ]

        request << new_superior.to_ber_contextspecific(0) if new_superior

        write(request.to_ber_appsequence(MODIFY_RDN_REQUEST), nil, message_id)

        pdu = queued_read(message_id)

        if !pdu || pdu.app_tag != Net::LDAP::PDU::ModifyRDNResponse
          raise ResponseMissingOrInvalidError, 'response missing or invalid'
        end

        pdu
      end

      def delete(dn:, control_codes: nil, message_id: next_msgid)
        controls = control_codes.to_ber_control if control_codes

        request  = dn.to_s.to_ber_application_string(DELETE_REQUEST)

        write(request, controls, message_id)

        pdu = queued_read(message_id)

        if !pdu || pdu.app_tag != Net::LDAP::PDU::DeleteResponse
          raise ResponseMissingOrInvalidError, 'response missing or invalid'
        end

        pdu
      end


    end
  end
end
