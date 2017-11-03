module ROM
  module LDAP
    module Update

      MODIFY_OPERATIONS = { add: 0, delete: 1, replace: 2 }.freeze

      def modify(dn:, operations:, message_id: next_msgid)

        pdu_request  = pdu(:modify_request)
        pdu_response = pdu(:modify_response)
        error_klass  = [ ResponseMissingOrInvalidError, 'response missing or invalid' ]

        ops = modify_ops(operations)

        request = [dn.to_ber, ops.to_ber_sequence].to_ber_appsequence(pdu_request)

        ldap_write(request, nil, message_id)

        pdu = queued_read(message_id)

        catch_error(pdu, error_klass, pdu_response)

        pdu
      end

      def rename(old_dn:, new_rdn:, delete_attrs: false, new_superior: nil, message_id: next_msgid)

        pdu_request  = pdu(:modify_rdn_request)
        pdu_response = pdu(:modify_rdn_response)
        error_klass  = [ ResponseMissingOrInvalidError, 'response missing or invalid' ]

        request = [old_dn, new_rdn, delete_attrs].map(&:to_ber)

        request << new_superior.to_ber_contextspecific(0) if new_superior

        ldap_write(request.to_ber_appsequence(pdu_request), nil, message_id)

        pdu = queued_read(message_id)

        catch_error(pdu, error_klass, pdu_response)

        pdu
      end

      def password_modify(dn:, old_pwd:, new_pwd:, message_id: next_msgid)

        pdu_request  = pdu(:extended_request)
        pdu_response = pdu(:extended_response)
        error_klass  = [ ResponseMissingError, 'response missing or invalid' ]

        context = PASSWORD_MODIFY.to_ber_contextspecific(0)
        payload = [ old_pwd.to_ber(0x81), new_pwd.to_ber(0x82) ]
        ext_seq = [ context, payload.to_ber_sequence.to_ber(0x81) ]
        request = ext_seq.to_ber_appsequence(pdu_request)

        ldap_write(request, nil, message_id)

        pdu = queued_read(message_id)

        catch_error(pdu, error_klass, pdu_response)

        pdu
      end

      private


      def modify_ops(operations = EMPTY_ARRAY)
        operations.each_with_object([]) do |(op, attrib, values), ops|

          op_ber = MODIFY_OPERATIONS[op.to_sym].to_ber_enumerated

          values = [values].flat_map { |v| v.to_ber if v }.to_ber_set

          values = [attrib.to_s.to_ber, values].to_ber_sequence

          ops << [op_ber, values].to_ber
        end
      end
    end

  end
end
