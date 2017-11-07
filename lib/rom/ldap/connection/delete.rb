using ::BER

module ROM
  module LDAP
    module Delete

      # @option control_codes [?]
      #
      # @option dn [String]
      #
      # @api public
      def delete(dn:, control_codes: nil)
        pdu_request  = pdu_lookup(:delete_request)
        pdu_response = pdu_lookup(:delete_response)
        error_klass  = [ ResponseMissingOrInvalidError, 'response missing or invalid' ]
        message_id   = next_msgid

        request      = dn.to_s.to_ber_application_string(pdu_request)
        controls     = control_codes.to_ber_control if control_codes

        ldap_write(request, controls, message_id)

        pdu = queued_read(message_id)

        validate_response(pdu, error_klass, pdu_response)

        pdu
      end

    end
  end
end
