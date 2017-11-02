module Modify

  MODIFY_OPERATIONS = { add: 0, delete: 1, replace: 2 }.freeze

  EXTENDED_REQUEST    = Net::LDAP::PDU::ExtendedRequest
  EXTENDED_RESPONSE   = Net::LDAP::PDU::ExtendedResponse

  MODIFY_REQUEST      = Net::LDAP::PDU::ModifyRequest
  MODIFY_RESPONSE     = Net::LDAP::PDU::ModifyResponse

  # ResponseMissingOrInvalidError = Class.new(StandardError)
  # ResponseMissingError          = Class.new(StandardError)


  def modify(
    dn:,
    operations:,
    message_id: next_msgid
  )

    pdu_request  = MODIFY_REQUEST
    pdu_response = MODIFY_RESPONSE
    error_klass  = [
      ResponseMissingOrInvalidError,
      'response missing or invalid'
    ]

    ops = modify_ops(operations)

    request = [dn.to_ber, ops.to_ber_sequence].to_ber_appsequence(pdu_request)

    ldap_write(request, nil, message_id)

    pdu = queued_read(message_id)

    raise(*error_klass) if (!pdu || pdu.app_tag != pdu_response)

    pdu
  end



  def password_modify(
    dn:,
    old_password: nil,
    new_password: nil,
    message_id: next_msgid
  )


    pdu_request  = EXTENDED_REQUEST
    pdu_response = EXTENDED_RESPONSE
    error_klass  = [
      ResponseMissingError,
      'response missing or invalid'
    ]

    ext_seq = [PASSWORD_MODIFY.to_ber_contextspecific(0)]

    unless old_password.nil?
      pwd_seq = [old_password.to_ber(0x81)]
      pwd_seq << new_password.to_ber(0x82) unless new_password.nil?
      ext_seq << pwd_seq.to_ber_sequence.to_ber(0x81)
    end

    request = ext_seq.to_ber_appsequence(pdu_request)

    ldap_write(request, nil, message_id)

    pdu = queued_read(message_id)

    raise(*error_klass) if (!pdu || pdu.app_tag != pdu_response)

    pdu
  end

  private


  def modify_ops(operations = EMPTY_ARRAY)
    operations.each_with_object([]) do |(op, attrib, values), ops|

      op_ber = MODIFY_OPERATIONS[op.to_sym].to_ber_enumerated

      # values = [values].flatten.map { |v| v.to_ber if v }.to_ber_set
      values = [values].flat_map { |v| v.to_ber if v }.to_ber_set

      values = [attrib.to_s.to_ber, values].to_ber_sequence

      ops << [op_ber, values].to_ber
    end
  end
end
