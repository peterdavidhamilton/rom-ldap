using ::BER

module ROM
  module LDAP
    module Authenticate
      # @option :username
      #
      # @option :password
      #
      # @option :method [Symbol] Defaults to simple.
      #
      # @api public
      def bind(username:, password:, version:, method: :simple)
        pdu_request  = pdu_lookup(:bind_request)
        pdu_response = pdu_lookup(:bind_result)
        error_klass  = [NoBindResultError, 'no bind result']
        message_id   = next_msgid

        request = [
          version.to_ber,
          username.to_ber,
          password.to_ber_contextspecific(0)

        ].to_ber_appsequence(pdu_request)

        ldap_write(request, nil, message_id)

        pdu = queued_read(message_id)

        validate_response(pdu, error_klass, pdu_response)

        pdu
      end

      # @option :filter [String] Should identify a single entity.
      #   Filtering by DN is recommended.
      #
      # @option :password [String]
      #
      # @return [Boolean] True if password matches first result.
      #
      # @api public
      def bind_as(filter:, password:)
        if entity = search(filter: filter, size: 1).first
          password = password.call if password.respond_to?(:call)

          bind(username: entity.dn, password: password) # ? entity : false
        end
      end

      # def setup_encryption(tls_options: {}, method:, timeout: nil, message_id: next_msgid)
      #   case method
      #   when :simple_tls
      #     @conn = wrap_with_ssl(@conn, tls_options, timeout)
      #   when :start_tls
      #     request = [
      #       START_TLS.to_ber_contextspecific(0)
      #     ].to_ber_appsequence(Net::LDAP::PDU::ExtendedRequest)
      #     ldap_write(request, nil, message_id)
      #     pdu = queued_read(message_id)
      #     if pdu.nil? || pdu.app_tag != Net::LDAP::PDU::ExtendedResponse
      #       raise Net::LDAP::NoStartTLSResultError, 'no start_tls result'
      #     end
      #     unless pdu.result_code.zero?
      #       raise Net::LDAP::StartTLSError,
      #             "start_tls failed: #{pdu.result_code}"
      #     end
      #     @conn = wrap_with_ssl(@conn, tls_options, timeout)
      #   else
      #     raise Net::LDAP::EncMethodUnsupportedError, "unsupported encryption method #{args[:method]}"
      #   end
      # end

      # module GetbyteForSSLSocket
      #   def getbyte
      #     getc.ord
      #   end
      # end

      # module FixSSLSocketSyncClose
      #   def close
      #     super
      #     io.close
      #   end
      # end

      # def wrap_with_ssl(io, tls_options = {}, timeout = nil)

      #   begin
      #     require 'openssl'
      #   rescue LoadError
      #     raise Net::LDAP::NoOpenSSLError, 'OpenSSL is unavailable'
      #   end

      #   ctx = OpenSSL::SSL::SSLContext.new

      #   ctx.set_params(tls_options) unless tls_options.empty?

      #   conn = OpenSSL::SSL::SSLSocket.new(io, ctx)

      #   begin
      #     if timeout
      #       conn.connect_nonblock
      #     else
      #       conn.connect
      #     end
      #   rescue IO::WaitReadable
      #     raise Errno::ETIMEDOUT, 'OpenSSL connection read timeout' unless
      #       IO.select([conn], nil, nil, timeout)
      #     retry
      #   rescue IO::WaitWritable
      #     raise Errno::ETIMEDOUT, 'OpenSSL connection write timeout' unless
      #       IO.select(nil, [conn], nil, timeout)
      #     retry
      #   end

      #   conn.extend(GetbyteForSSLSocket) unless conn.respond_to?(:getbyte)
      #   conn.extend(FixSSLSocketSyncClose)

      #   conn
      # end
    end
  end
end
