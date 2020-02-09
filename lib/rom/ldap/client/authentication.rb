begin
  # TODO: Windows NTLM authentication
  # @see https://github.com/winrb/rubyntlm
  require 'rubyntlm'
rescue LoadError
  # ntlm_bind
end

module ROM
  module LDAP
    # @api private
    class Client

      using ::BER

      # Adds authentication capability to the client.
      #
      # @api private
      module Authentication
        #
        # The Bind request is defined as follows:
        #
        #       BindRequest ::= [APPLICATION 0] SEQUENCE {
        #            version                 INTEGER (1 ..  127),
        #            name                    LDAPDN,
        #            authentication          AuthenticationChoice }
        #
        #       AuthenticationChoice ::= CHOICE {
        #            simple                  [0] OCTET STRING,
        #                                    -- 1 and 2 reserved
        #            sasl                    [3] SaslCredentials,
        #            ...  }
        #
        #       SaslCredentials ::= SEQUENCE {
        #            mechanism               LDAPString,
        #            credentials             OCTET STRING OPTIONAL }
        #
        # @see https://tools.ietf.org/html/rfc4511#section-4.2
        # @see https://tools.ietf.org/html/rfc4513
        #
        #
        # @option :username [String]
        #
        # @option :password [String]
        #
        # @return [PDU] result object
        #
        # @api public
        def bind(username:, password:)
          request_type = pdu_lookup(:bind_request)

          request = [
            3.to_ber,
            username.to_ber,
            password.to_ber_contextspecific(0)
          ].to_ber_appsequence(request_type)

          submit(:bind_result, request)
        end

        #
        #
        # @return [PDU] result object
        #
        # @api private
        def start_tls
          request_type = pdu_lookup(:extended_request)

          request = [
            OID[:start_tls].to_ber_contextspecific(0)
          ].to_ber_appsequence(request_type)

          submit(:extended_response, request)
        end

        def sasl_bind(mechanism:, credentials:, challenge:)
          request_type = pdu_lookup(:bind_request)
          n = 0

          loop do
            sasl = [
              mechanism.to_ber,
              credentials.to_ber
            ].to_ber_contextspecific(3)

            request = [
              3.to_ber,
              EMPTY_STRING.to_ber,
              sasl
            ].to_ber_appsequence(request_type)

            raise Error, 'sasl-challenge overflow' if (n += 1) > 10

            pdu = submit(:bind_request, request)

            credentials = challenge.call(pdu.result_server_sasl_creds)
          end
        end
      end

    end
  end
end
