using ::BER

module ROM
  module LDAP
    module Update

      #
      # @api public
      def modify(dn:, operations:)
        pdu_request  = pdu_lookup(:modify_request)
        pdu_response = pdu_lookup(:modify_response)
        error_klass  = [ ResponseMissingOrInvalidError, 'response missing or invalid' ]
        message_id   = next_msgid
        ops          = modify_ops(operations)

        request = [dn.to_ber, ops.to_ber_sequence].to_ber_appsequence(pdu_request)

        ldap_write(request, nil, message_id)

        pdu = queued_read(message_id)

        validate_response(pdu, error_klass, pdu_response)

        pdu
      end

      #
      # @api public
      def rename(old_dn:, new_rdn:, delete_attrs: false, new_superior: nil)
        pdu_request  = pdu_lookup(:modify_rdn_request)
        pdu_response = pdu_lookup(:modify_rdn_response)
        error_klass  = [ ResponseMissingOrInvalidError, 'response missing or invalid' ]
        message_id   = next_msgid

        request = [old_dn, new_rdn, delete_attrs].map(&:to_ber)

        request << new_superior.to_ber_contextspecific(0) if new_superior

        ldap_write(request.to_ber_appsequence(pdu_request), nil, message_id)

        pdu = queued_read(message_id)

        validate_response(pdu, error_klass, pdu_response)

        pdu
      end

      #
      # @api public
      def password_modify(dn:, old_pwd:, new_pwd:)
        pdu_request  = pdu_lookup(:extended_request)
        pdu_response = pdu_lookup(:extended_response)
        error_klass  = [ ResponseMissingError, 'response missing or invalid' ]
        message_id   = next_msgid

        context = PASSWORD_MODIFY.to_ber_contextspecific(0)
        payload = [ old_pwd.to_ber(0x81), new_pwd.to_ber(0x82) ]
        ext_seq = [ context, payload.to_ber_sequence.to_ber(0x81) ]
        request = ext_seq.to_ber_appsequence(pdu_request)

        ldap_write(request, nil, message_id)

        pdu = queued_read(message_id)

        validate_response(pdu, error_klass, pdu_response)

        pdu
      end

      private

      MODIFY_OPERATIONS = { add: 0, delete: 1, replace: 2 }.freeze

      def modify_ops(operations = EMPTY_ARRAY)
        operations.each_with_object([]) do |(op, attr, values), ops|

          op_ber = MODIFY_OPERATIONS[op.to_sym].to_ber_enumerated

          values = [values].flat_map { |v| v.to_ber if v }.to_ber_set

          values = [attr.to_s.to_ber, values].to_ber_sequence

          ops << [op_ber, values].to_ber
        end
      end
    end

  end
end
