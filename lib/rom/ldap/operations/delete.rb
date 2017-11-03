using ::BER

module ROM
  module LDAP
    module Delete

      def delete(dn:, control_codes: nil, message_id: next_msgid)

        pdu_request  = pdu(:delete_request)
        pdu_response = pdu(:delete_response)
        error_klass  = [ ResponseMissingOrInvalidError, 'response missing or invalid' ]

        request  = dn.to_s.to_ber_application_string(pdu_request)

        controls = control_codes.to_ber_control if control_codes

        ldap_write(request, controls, message_id)

        pdu = queued_read(message_id)

        catch_error(pdu, error_klass, pdu_response)

        pdu
      end

    end
  end
end
