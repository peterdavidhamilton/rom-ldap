require 'ostruct'

module BER
  class PDU
    Error = Class.new(RuntimeError)

    INVALID_SEARCH = OpenStruct.new(
        status:      :failure,
        result_code: ::BER::ResultCode['OperationsError'],
        message:    'Invalid search'
      ).freeze

    RR = ::BER::ResponseRequest

    attr_reader :message_id
    alias msg_id message_id
    attr_reader :app_tag
    attr_reader :search_entry
    attr_reader :search_referrals
    attr_reader :search_parameters
    attr_reader :bind_parameters
    attr_reader :extended_response
    attr_reader :ldap_controls
    alias result_controls ldap_controls

    def initialize(ber_object)
      begin
        @message_id     = ber_object[0].to_i
        @app_tag        = ber_object[1].ber_identifier & 0x1f
        @ldap_controls  = []
      rescue Exception => e
        raise Error, "LDAP PDU Format Error: #{e.message}"
      end

      case @app_tag
      when RR[:bind_result]             then parse_bind_response(ber_object[1])
      when RR[:search_returned_data]    then parse_search_return(ber_object[1])
      when RR[:search_result_referral]  then parse_search_referral(ber_object[1])
      when RR[:search_result]           then parse_ldap_result(ber_object[1])
      when RR[:modify_response]         then parse_ldap_result(ber_object[1])
      when RR[:add_response]            then parse_ldap_result(ber_object[1])
      when RR[:delete_response]         then parse_ldap_result(ber_object[1])
      when RR[:modify_rdn_response]     then parse_ldap_result(ber_object[1])
      when RR[:search_request]          then parse_ldap_search_request(ber_object[1])
      when RR[:bind_request]            then parse_bind_request(ber_object[1])
      when RR[:unbind_request]          then parse_unbind_request(ber_object[1])
      when RR[:extended_response]       then parse_extended_response(ber_object[1])
      else
        raise LdapPduError, "unknown pdu-type: #{@app_tag}"
      end


      parse_controls(ber_object[2]) if ber_object[2]
    end

    def result
      @ldap_result || {}
    end

    def error_message
      result[:errorMessage] || EMPTY_STRING
    end

    def result_code(code = :resultCode)
      @ldap_result && @ldap_result[code]
    end

    def status
      Net::LDAP::ResultCodesNonError.include?(result_code) ? :success : :failure
    end

    def success?
      status == :success
    end

    def failure?
      !success?
    end

    def result_server_sasl_creds
      @ldap_result && @ldap_result[:serverSaslCreds]
    end

    private

    def parse_ldap_result(sequence)
      (sequence.length >= 3) || raise(Error, 'Invalid LDAP result length.')

      @ldap_result = {
        resultCode:   sequence[0],
        matchedDN:    sequence[1],
        errorMessage: sequence[2]
      }

      parse_search_referral(sequence[3]) if @ldap_result[:resultCode] == ResultCode['Referral']
    end

    def parse_extended_response(sequence)
      (sequence.length >= 3) || raise(Error, 'Invalid LDAP result length.')

      @ldap_result = {
        resultCode:   sequence[0],
        matchedDN:    sequence[1],
        errorMessage: sequence[2]
      }

      @extended_response = sequence[3]
    end

    def parse_bind_response(sequence)
      (sequence.length >= 3) || raise(Error, 'Invalid LDAP Bind Response length.')
      parse_ldap_result(sequence)
      @ldap_result[:serverSaslCreds] = sequence[3] if sequence.length >= 4
      @ldap_result
    end

    def parse_search_return(sequence)
      (sequence.length >= 2) || raise(Error, 'Invalid Search Response length.')

      @search_entry = Hash.new(sequence[0])

      # @search_entry = Net::LDAP::Entry.new(sequence[0])
      sequence[1].each { |seq| @search_entry[seq[0]] = seq[1] }
    end

    def parse_search_referral(uris)
      @search_referrals = uris
    end

    def parse_controls(sequence)
      @ldap_controls = sequence.map do |control|
        o             = OpenStruct.new
        o.oid         = control[0]
        o.criticality = control[1]
        o.value       = control[2]

        if o.criticality && o.criticality.is_a?(String)
          o.value       = o.criticality
          o.criticality = false
        end
        o
      end
    end

    def parse_ldap_search_request(sequence)
      s = OpenStruct.new
      s.base_object, s.scope, s.deref_aliases, s.size_limit, s.time_limit,
        s.types_only, s.filter, s.attributes = sequence
      @search_parameters = s
    end

    def parse_bind_request(sequence)
      s = OpenStruct.new
      s.version, s.name, s.authentication = sequence
      @bind_parameters = s
    end

    def parse_unbind_request(_sequence)
      nil
    end
  end
end
