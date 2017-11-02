module ROM
  module LDAP
    module Create

      ADD_REQUEST  = Net::LDAP::PDU::AddRequest
      ADD_RESPONSE = Net::LDAP::PDU::AddResponse

      def add(
        dn:,
        attributes: EMPTY_ARRAY,
        message_id: next_msgid
      )

        pdu_request  = ADD_REQUEST
        pdu_response = ADD_RESPONSE
        error_klass  = [
          ResponseMissingOrInvalidError,
          'response missing or invalid'
        ]

        add_attrs = []

        (a = attributes) && a.each do |k, v|
          add_attrs << [k.to_s.to_ber, Array(v).map(&:to_ber).to_ber_set].to_ber_sequence
        end

        request = [dn.to_ber, add_attrs.to_ber_sequence].to_ber_appsequence(pdu_request)

        ldap_write(request, nil, message_id)

        pdu = queued_read(message_id)

        catch_error(pdu, error_klass, pdu_response)

        pdu
      end


    end
  end
end
