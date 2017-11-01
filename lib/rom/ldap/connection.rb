# cwd = File.expand_path(File.join(File.dirname(__FILE__), '../../../lib'))
# $LOAD_PATH.unshift(cwd)

require 'rom/ldap/constants'

# Load Core Extensions
require 'net/ber'
require 'net/ldap/pdu' # socket ldap read
require 'psych'

compile_syntax = Psych.load_file('./lib/rom/ldap/syntax.yaml')
AsnSyntax      = Net::BER.compile_syntax(compile_syntax).freeze

require 'net/tcp_client'

module ROM
  module LDAP
    class Connection < Net::TCPClient


      # This is defined in lib/net/ldap.rb but appears in lib/net/ldap/pdu.rb:180
      ::Net::LDAP::ResultCodeReferral = 10


      def ldap_search(
          base:  'ou=users,dc=example,dc=com',
          filter: 'dn=*',
          scope: SCOPE_SUBTREE,
          deref: DEREF_NEVER,

          # scope: SCOPE_BASE_OBJECT,
          # deref: DEREF_ALWAYS,

          attrs_only: false,
          time: 30,
          # attrs: [:dn, :cn, :sn]
          attrs: []
          )

        rfc2696_cookie = [126, '']
        result_pdu     = nil
        n_results      = 0
        message_id     = next_msgid

        cookie_to_ber  = rfc2696_cookie.map(&:to_ber).to_ber_sequence.to_s.to_ber

        # should collect this into a private helper to clarify the structure
        loop do

          query_limit = 10
# binding.pry
#           if size > 0
#             query_limit = if paged
#                             (((size - n_results) < 126) ? (size - n_results) : 0)
#                           else
#                             size
#                           end
#           end


          ber_attrs = attrs.map { |attr| attr.to_s.to_ber }


          request = [
            base.to_ber,                    # ou=users,dc=example,dc=com
            scope.to_ber_enumerated,        # SCOPE_SUBTREE   or 2
            deref.to_ber_enumerated,        # DEREF_NEVER     or 0
            query_limit.to_ber,             # size limit
            time.to_ber,                    # 30
            attrs_only.to_ber,              # true/false
            filter.to_ber,                  # 'objectclass=*' or   Net::LDAP::Filter.eq("objectClass", "*")
            ber_attrs.to_ber_sequence,      # [:dn, :cn, :sn].map { |attr| attr.to_s.to_ber }.to_ber_sequence
          # ].to_ber_appsequence(Net::LDAP::PDU::SearchRequest)  # Net::LDAP::PDU::SearchRequest = 3
          ].to_ber_appsequence(3)  # Net::LDAP::PDU::SearchRequest = 3

          # switch for paged results
          paged = true

          controls = []

          controls <<
            [
              PAGED_RESULTS.to_ber,  # => "\x04\x161.2.840.113556.1.4.319"
              false.to_ber,          # Criticality MUST be false to interoperate with normal LDAPs.

              # rfc2696_cookie.map(&:to_ber).to_ber_sequence.to_s.to_ber,
              cookie_to_ber          # => "\x04\a0\x05\x02\x01~\x04\x00"
            ].to_ber_sequence if paged

          # controls << ber_sort if ber_sort

          # controls become nil or apply to_ber_contextspecific(0)
          controls = controls.empty? ? nil : controls.to_ber_contextspecific(0)


          # binding.pry
          # request     => "c4\x04\x1Aou=users,dc=example,dc=com\n\x01\x02\n\x01\x00\x02\x01\n\x02\x01\x1E\x01\x01\x00\x04\x05uid=*0\x00"
          # request     => "cH\x04\x1Aou=users,dc=example,dc=com\n\x01\x02\n\x01\x00\x02\x01\n\x02\x01\x1E\x01\x01\x00\x04\robjectclass=*0\f\x04\x02dn\x04\x02cn\x04\x02sn"
          # controls    => "\xA0&0$\x04\x161.2.840.113556.1.4.319\x01\x01\x00\x04\a0\x05\x02\x01~\x04\x00"
          # message_id  => 1
          #
          ldap_write(request, controls, message_id) # =>


          # reset controls and pdu
          result_pdu = nil
          controls   = []

          while pdu = queued_read(message_id)
            puts "#{self.class}##{__callee__}: while loop #{pdu} "

            case pdu.app_tag
            when Net::LDAP::PDU::SearchReturnedData
              n_results += 1
              if block_given?
                binding.pry
                yield pdu.search_entry
              end
            when Net::LDAP::PDU::SearchResultReferral
              if refs
                if block_given?
                  binding.pry
                  se = Net::LDAP::Entry.new
                  se[:search_referrals] = (pdu.search_referrals || [])
                  yield se
                end
              end
            when Net::LDAP::PDU::SearchResult
              result_pdu = pdu
              controls = pdu.result_controls
              if refs && pdu.result_code == 10 # Net::LDAP::ResultCodeReferral
                if block_given?
                  binding.pry
                  se = Net::LDAP::Entry.new
                  se[:search_referrals] = (pdu.search_referrals || [])
                  yield se
                end
              end
              break
            else
              abort "invalid response-type in search: #{pdu.app_tag}"
            end
          end # while end

        # binding.pry
        end # loop end

      # rescue Net::TCPClient::ConnectionFailure
      end

      # private



    # Defines the Protocol Data Unit (PDU) for LDAP.
    # An LDAP PDU always looks like a BER SEQUENCE with at least two elements:
    # an INTEGER message ID number and
    # an application-specific SEQUENCE.





    # Net::LDAP::AuthAdapter::Simple #connection
    def bind(auth = { method: :anonymous })

      # meth = auth[:method]
      # adapter = Net::LDAP::AuthAdapter[meth]
      # adapter.new(self).bind(auth)


      # user, psw = if auth[:method] == :simple
      #               [auth[:username] || auth[:dn], auth[:password]]
      #             else
      #               ["", ""]
      #             end

      user, psw = 'uid=admin,ou=system', 'secret'

      # raise Net::LDAP::BindingInformationInvalidError, "Invalid binding information" unless (user && psw)

      message_id = next_msgid

      request    = [
        3.to_ber, # Net::LDAP::Connection::LdapVersion.to_ber,   # api.vendor_version = 3
        user.to_ber,
        psw.to_ber_contextspecific(0)
      ].to_ber_appsequence(Net::LDAP::PDU::BindRequest)

      # @connection.send(:write, request, nil, message_id)
      ldap_write(request, nil, message_id)

      pdu = queued_read(message_id)

      if !pdu || pdu.app_tag != 1 #  Net::LDAP::PDU::BindResult  BindResult = 1
        abort "no bind result"
      end

      puts "#{self.class}##{__callee__}: #{pdu} "

      pdu
    end


    # def socket_connect(socket, address, timeout)
    #   binding.pry
    #   super
    # end


# ResultCodeSuccess                      = 0
#   ResultCodeOperationsError              = 1
#   ResultCodeProtocolError                = 2
#   ResultCodeTimeLimitExceeded            = 3
#   ResultCodeSizeLimitExceeded            = 4
#   ResultCodeCompareFalse                 = 5
#   ResultCodeCompareTrue                  = 6
#   ResultCodeAuthMethodNotSupported       = 7
#   ResultCodeStrongerAuthRequired         = 8
#   ResultCodeReferral                     = 10
#   ResultCodeAdminLimitExceeded           = 11
#   ResultCodeUnavailableCriticalExtension = 12
#   ResultCodeConfidentialityRequired      = 13
#   ResultCodeSaslBindInProgress           = 14
#   ResultCodeNoSuchAttribute              = 16
#   ResultCodeUndefinedAttributeType       = 17
#   ResultCodeInappropriateMatching        = 18
#   ResultCodeConstraintViolation          = 19
#   ResultCodeAttributeOrValueExists       = 20
#   ResultCodeInvalidAttributeSyntax       = 21
#   ResultCodeNoSuchObject                 = 32
#   ResultCodeAliasProblem                 = 33
#   ResultCodeInvalidDNSyntax              = 34
#   ResultCodeAliasDereferencingProblem    = 36
#   ResultCodeInappropriateAuthentication  = 48
#   ResultCodeInvalidCredentials           = 49
#   ResultCodeInsufficientAccessRights     = 50
#   ResultCodeBusy                         = 51
#   ResultCodeUnavailable                  = 52
#   ResultCodeUnwillingToPerform           = 53
#   ResultCodeNamingViolation              = 64
#   ResultCodeObjectClassViolation         = 65
#   ResultCodeNotAllowedOnNonLeaf          = 66
#   ResultCodeNotAllowedOnRDN              = 67
#   ResultCodeEntryAlreadyExists           = 68
#   ResultCodeObjectClassModsProhibited    = 69
#   ResultCodeAffectsMultipleDSAs          = 71
#   ResultCodeOther                        = 80






      # Net::LDAP::Connection#write
      def ldap_write(request, controls = nil, message_id = next_msgid, timeout = write_timeout)
        packet = [message_id.to_ber, request, controls].compact.to_ber_sequence
        puts "#{self.class}##{__callee__}: #{packet} "

        # write(packet) # Net::TCPClient#write
        # socket_write(packet, timeout)
        socket.write(packet)
      rescue Exception => exc
        binding.pry
        close if close_on_error
        raise exc
      end


      # def write(data, timeout = write_timeout)
      #   data = data.to_s
      #   if respond_to?(:logger)
      #     payload        = {timeout: timeout}
      #     # With trace level also log the sent data
      #     payload[:data] = data if logger.trace?
      #     logger.benchmark_debug('#write', payload: payload) do
      #       payload[:bytes] = socket_write(data, timeout)
      #     end
      #   else
      #     socket_write(data, timeout)
      #   end
      # rescue Exception => exc
      #   close if close_on_error
      #   raise exc
      # end


      # Net::LDAP::Connection#read
      def ldap_read(syntax = AsnSyntax)
        # Check out socket read_ber
        if ber_object = socket.read_ber(syntax)
          puts "#{self.class}##{__callee__}: #{ber_object} "
        else
          return
        end

        # ber_object = [0, [2, "", "PROTOCOL_ERROR: The server will disconnect!", 18400597803079440689678002902069631524796887079072566]]

        foo = Net::LDAP::PDU.new(ber_object)
        puts "#{self.class}##{__callee__}: #{foo} "

        foo
      end


      # Internal message queue
      #
      # @return [whatever you put in]
      #
      # @example
      #   queue[1]       => []
      #   queue['hello'] => []
      #   queue          => { 1 => [], "hello" => [] }
      #
      # @api private
      def message_queue
        @message_queue ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def next_msgid
        @msgid ||= 0
        @msgid += 1
      end

      def queued_read(message_id)
        if pdu = message_queue[message_id].shift
          return pdu
        end

        # read messages until we have a match for the given message_id
        while pdu = ldap_read
          return pdu if pdu.message_id == message_id

          message_queue[pdu.message_id].push pdu
          next
        end

        puts "#{self.class}##{__callee__}: #{pdu} "

        pdu
      end



    end
  end
end


 # module GetbyteForSSLSocket
 #    def getbyte
 #      getc.ord
 #    end
 #  end

 #  module FixSSLSocketSyncClose
 #    def close
 #      super
 #      io.close
 #    end
 #  end







# use_connection({}) { |e| e.socket.local_address  } # => 2


# /lib/net/ldap.rb - move to dataset to create and yield to a connection

# def use_connection(args)
#     if @open_connection
#       yield @open_connection
#     else
#       begin
#         conn = new_connection
#         result = conn.bind(args[:auth] || @auth)
#         return result unless result.result_code == Net::LDAP::ResultCodeSuccess
#         yield conn
#       ensure
#         conn.close if conn
#       end
#     end
#   end



$connection = ROM::LDAP::Connection.connect(
  servers: ['127.0.0.1:10389'],
  # server: '127.0.0.1:10389',
  # connect_timeout: 5,
  write_timeout: -1,
  read_timeout: -1, # wait forever
  # proxy_server: nil
  ) do |c|

# binding.pry
  puts c.socket.remote_address           # => #<Addrinfo: 127.0.0.1:10389 TCP>
  puts c.socket.local_address            # => #<Addrinfo: 127.0.0.1:49899 TCP>
  puts c.bind                            # => #<Net::LDAP::PDU:0x00007ff785391898 @app_tag=1, @ldap_controls=[], @ldap_result={:resultCode=>0, :matchedDN=>"", :errorMessage=>""}, @message_id=1>
  puts c.ldap_search(filter: '(uid=*)')  # =>

end

# connection # =>
