using ::BER

module ROM
  module LDAP
    class Connection < Net::TCPClient
      # LDAP::Connection entry modification methods
      #
      module Update
        # @option :dn [String] distinguished name
        #
        # @option :ops [Array<Mixed>] operation ast
        #
        # @return [PDU] result object
        #
        # @api public
        def modify(dn:, ops:)
          pdu_request = pdu_lookup(:modify_request)
          message_id  = next_msgid
          operations  = modify_ops(ops)

          request = [dn.to_ber, operations.to_ber_sequence].to_ber_appsequence(pdu_request)

          ldap_write(request, nil, message_id)

          result = queued_read(message_id)

          validate_pdu(result: result, response: :modify_response)
        end

        # @option :old_dn [String] current distinguished name
        #
        # @option :new_rdn [String] replacement relative distinguished name
        #
        # @option :delete_attrs [Array]
        #
        # @option :new_superior [?]
        #
        # @return [PDU] result object
        #
        # @api public
        def rename(old_dn:, new_rdn:, delete_attrs: false, new_superior: nil)
          pdu_request = pdu_lookup(:modify_rdn_request)
          message_id  = next_msgid

          request = [old_dn, new_rdn, delete_attrs].map(&:to_ber)
          request << new_superior.to_ber_contextspecific(0) if new_superior
          request = request.to_ber_appsequence(pdu_request)

          ldap_write(request, nil, message_id)

          result = queued_read(message_id)

          validate_pdu(result: result, response: :modify_rdn_response)
        end

        # @option :dn [String] distinguished name
        #
        # @option :old_pwd [String] current password
        #
        # @option :new_pwd [String] replacement password
        #
        # @return [PDU] result object
        #
        # @api public
        def password_modify(dn:, old_pwd:, new_pwd:)
          pdu_request = pdu_lookup(:extended_request)
          message_id  = next_msgid
          context     = PASSWORD_MODIFY.to_ber_contextspecific(0)
          payload     = [old_pwd.to_ber(0x81), new_pwd.to_ber(0x82)]
          ext_seq     = [context, payload.to_ber_sequence.to_ber(0x81)]
          request     = ext_seq.to_ber_appsequence(pdu_request)

          ldap_write(request, nil, message_id)
          result = queued_read(message_id)

          validate_pdu(result: result, response: :extended_response)
        end

        private

        # Encode operation AST to BER
        #
        # @param operations [Array]
        #
        # @return [Array] BER encoded operations
        #
        # @api private
        def modify_ops(operations = EMPTY_ARRAY)
          operations.each_with_object([]) do |(op, attr, values), ops|
            op_ber = MODIFY_OPERATIONS[op].to_ber_enumerated
            values = [values].flat_map { |v| v&.to_ber }.to_ber_set
            values = [attr.to_s.to_ber, values].to_ber_sequence

            ops << [op_ber, values].to_ber
          end
        end
      end
    end
  end
end
