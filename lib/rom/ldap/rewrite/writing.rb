module Writing

  # MODIFY_OPERATIONS = { add: 0, delete: 1, replace: 2 }.freeze


  ADD_REQUEST         = Net::LDAP::PDU::AddRequest
  ADD_RESPONSE        = Net::LDAP::PDU::AddResponse
  DELETE_REQUEST      = Net::LDAP::PDU::DeleteRequest
  DELETE_RESPONSE     = Net::LDAP::PDU::DeleteResponse
  # EXTENDED_REQUEST    = Net::LDAP::PDU::ExtendedRequest
  # EXTENDED_RESPONSE   = Net::LDAP::PDU::ExtendedResponse
  MODIFY_RDN_REQUEST  = Net::LDAP::PDU::ModifyRDNRequest
  MODIFY_RDN_RESPONSE = Net::LDAP::PDU::ModifyRDNResponse
  # MODIFY_REQUEST      = Net::LDAP::PDU::ModifyRequest
  # MODIFY_RESPONSE     = Net::LDAP::PDU::ModifyResponse

  ResponseMissingOrInvalidError = Class.new(StandardError)
  ResponseMissingError          = Class.new(StandardError)


  # def modify(
  #   dn:,
  #   operations:,
  #   message_id: next_msgid
  # )

  #   pdu_request  = MODIFY_REQUEST
  #   pdu_response = MODIFY_RESPONSE
  #   error_klass  = [
  #     ResponseMissingOrInvalidError,
  #     'response missing or invalid'
  #   ]

  #   ops = modify_ops(operations)

  #   request = [dn.to_ber, ops.to_ber_sequence].to_ber_appsequence(pdu_request)

  #   ldap_write(request, nil, message_id)

  #   pdu = queued_read(message_id)

  #   raise(*error_klass) if (!pdu || pdu.app_tag != pdu_response)

  #   pdu
  # end

  # def password_modify(
  #   dn:,
  #   old_password: nil,
  #   new_password: nil,
  #   message_id: next_msgid
  # )


  #   pdu_request  = EXTENDED_REQUEST
  #   pdu_response = EXTENDED_RESPONSE
  #   error_klass  = [
  #     ResponseMissingError,
  #     'response missing or invalid'
  #   ]

  #   ext_seq = [PASSWORD_MODIFY.to_ber_contextspecific(0)]

  #   unless old_password.nil?
  #     pwd_seq = [old_password.to_ber(0x81)]
  #     pwd_seq << new_password.to_ber(0x82) unless new_password.nil?
  #     ext_seq << pwd_seq.to_ber_sequence.to_ber(0x81)
  #   end

  #   request = ext_seq.to_ber_appsequence(pdu_request)

  #   ldap_write(request, nil, message_id)

  #   pdu = queued_read(message_id)

  #   raise(*error_klass) if (!pdu || pdu.app_tag != pdu_response)

  #   pdu
  # end

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

    raise(*error_klass) if (!pdu || pdu.app_tag != pdu_response)

    pdu
  end

  def rename(
    old_dn:,
    new_rdn:,
    delete_attrs: false,
    new_superior: nil,
    message_id: next_msgid
  )


    pdu_request  = MODIFY_RDN_REQUEST
    pdu_response = MODIFY_RDN_RESPONSE
    error_klass  = [
      ResponseMissingOrInvalidError,
      'response missing or invalid'
    ]

    # request = [old_dn.to_ber, new_rdn.to_ber, delete_attrs.to_ber]

    request = [old_dn, new_rdn, delete_attrs].map(&:to_ber)

    request << new_superior.to_ber_contextspecific(0) if new_superior

    ldap_write(request.to_ber_appsequence(pdu_request), nil, message_id)

    pdu = queued_read(message_id)

    raise(*error_klass) if (!pdu || pdu.app_tag != pdu_response)

    pdu
  end

  def delete(
    dn:,
    control_codes: nil,
    message_id: next_msgid
  )


    pdu_request  = DELETE_REQUEST
    pdu_response = DELETE_RESPONSE
    error_klass  = [
      ResponseMissingOrInvalidError,
      'response missing or invalid'
    ]

    request  = dn.to_s.to_ber_application_string(pdu_request)

    controls = control_codes.to_ber_control if control_codes

    ldap_write(request, controls, message_id)

    pdu = queued_read(message_id)

    raise(*error_klass) if (!pdu || pdu.app_tag != pdu_response)

    pdu
  end


  private


  # def modify_ops(operations = EMPTY_ARRAY)
  #   operations.each_with_object([]) do |(op, attrib, values), ops|

  #     op_ber = MODIFY_OPERATIONS[op.to_sym].to_ber_enumerated

  #     # values = [values].flatten.map { |v| v.to_ber if v }.to_ber_set
  #     values = [values].flat_map { |v| v.to_ber if v }.to_ber_set

  #     values = [attrib.to_s.to_ber, values].to_ber_sequence

  #     ops << [op_ber, values].to_ber
  #   end
  # end
end
