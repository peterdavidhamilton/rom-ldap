using ::BER

module ROM
  module LDAP
    class Connection < Net::TCPClient
      # LDAP::Connection entry deletion methods
      #
      module Delete
        # @option :dn [String] distinguished name
        #
        # @option :control_codes [?]
        #
        # @api public
        def delete(dn:, control_codes: nil)
          connect
          pdu_request = pdu_lookup(:delete_request)
          request     = dn.to_s.to_ber_application_string(pdu_request)
          controls    = control_codes.to_ber_control if control_codes
          message_id  = next_msgid

          ldap_write(request, controls, message_id)

          result = queued_read(message_id)

          validate_pdu(result: result, response: :delete_response)
        end
      end
    end
  end
end
