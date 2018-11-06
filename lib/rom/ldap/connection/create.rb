using ::BER

module ROM
  module LDAP
    class Connection < Net::TCPClient
      # LDAP::Connection entry creation methods
      #
      module Create
        #
        # @option :dn [String] distinguished name
        # @option :attrs [Array]
        #
        # @api public
        def add(dn:, attrs: EMPTY_ARRAY)
          pdu_request = pdu_lookup(:add_request)
          message_id  = next_msgid

          ber_attrs = attrs.each_with_object([]) do |(k, v), attributes|
            ber_values = Array(v).map { |v| v.to_ber }.to_ber_set
            attributes << [k.to_s.to_ber, ber_values].to_ber_sequence
          end

          request = [
            dn.to_ber,
            ber_attrs.to_ber_sequence
          ].to_ber_appsequence(pdu_request)

          ldap_write(request, nil, message_id)
          result = queued_read(message_id)

          validate_pdu(result: result, response: :add_response)
        end
      end
    end
  end
end
