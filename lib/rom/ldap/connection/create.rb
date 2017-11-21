using ::BER

module ROM
  module LDAP
    class Connection < Net::TCPClient
      # LDAP::Connection entry creation methods
      #
      module Create
        # @option :dn [String] distinguished name
        #
        # @option :attrs [Array]
        #
        # @api public
        def add(dn:, attrs: EMPTY_ARRAY)
          pdu_request  = pdu_lookup(:add_request)
          pdu_response = pdu_lookup(:add_response)
          error_klass  = [ResponseMissingOrInvalidError, 'response missing or invalid']
          message_id   = next_msgid

          ber_attrs    = attrs.each_with_object([]) do |(k, v), attributes|
            ber_values = Array(v).map(&:to_ber).to_ber_set
            attributes << [k.to_s.to_ber, ber_values].to_ber_sequence
          end

          request = [dn.to_ber, ber_attrs.to_ber_sequence].to_ber_appsequence(pdu_request)
          ldap_write(request, nil, message_id)
          pdu = queued_read(message_id)
          validate_response(pdu, error_klass, pdu_response)
          pdu
        end
      end
    end
  end
end
