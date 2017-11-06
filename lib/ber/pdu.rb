require 'ostruct'
require 'ber/struct'

module BER
  class PDU
    Error = Class.new(RuntimeError)

    SUCCESS_CODES = [
      :success,
      :compare_true,
      :compare_false,
      :referral,
      :sasl_bind_in_progress
    ].freeze

    # ResultCodeSearchSuccess = [
    #   :success,
    #   :time_limit_exceeded,
    #   :size_limit_exceeded
    # ].freeze

    # @param ber_object [Array]
    #
    def initialize(ber_object)
      begin
        message, tag, third_bit = ber_object
        @message_id     = message.to_i
        @app_tag        = tag.ber_identifier & 0x1f

        @ldap_controls  = []
        @ldap_result    = {}

      rescue Exception => e
        raise Error, "LDAP PDU Format Error: #{e.message}"
      end

      parse_tag(pdu_type, tag)
      parse_controls(third_bit) if third_bit
    end

    attr_reader :message_id
    attr_reader :message
    attr_reader :info
    attr_reader :app_tag
    attr_reader :ldap_controls
    attr_reader :bind_parameters
    attr_reader :extended_response
    attr_reader :search_entry
    attr_reader :search_parameters
    attr_reader :search_referrals

    alias msg_id message_id
    alias result_controls ldap_controls

    def inspect
      %(<##{self.class}
        type=#{pdu_type}
        result_code=#{result_code}
        message=#{message}
        info=#{info}
        success?=#{success?}
        referral?=#{referral?}
        failure?=#{failure?}
        error_message=#{error_message}
        matched_dn=#{matched_dn}
        bind_as=#{bind_parameters}
        >
        )
    end

    alias to_s inspect

    def result
      @ldap_result
    end

    def error_message
      @ldap_result.fetch(:errorMessage, :missing)
    end

    def result_code
      @ldap_result.fetch(:resultCode, :missing)
    end

    def matched_dn
      @ldap_result.fetch(:matchedDN, EMPTY_STRING)
    end

    def result_server_sasl_creds
      @ldap_result.fetch(:serverSaslCreds)
    end

    def referral?
      result_code == 10
    end

    def success?
      SUCCESS_CODES.include?(@result_symbol)
    end

    def failure?
      !success?
    end


    private

    def parse_tag(pdu_type, tag)
      case pdu_type
      # Authenticaton
      when :bind_request            then parse_bind_request(tag)
      when :bind_result             then parse_bind_response(tag)
      when :unbind_request          then parse_unbind_request(tag)
      # Searching
      when :search_request          then parse_ldap_search_request(tag)
      when :search_result_referral  then parse_search_referral(tag)
      when :search_returned_data    then parse_search_return(tag)
      # Operation Results
      when :search_result           then parse_ldap_result(tag)
      when :add_response            then parse_ldap_result(tag)
      when :delete_response         then parse_ldap_result(tag)
      when :modify_response         then parse_ldap_result(tag)
      when :modify_rdn_response     then parse_ldap_result(tag)
      # Extended
      when :extended_response       then parse_extended_response(tag)
      end
    end

    def check_sequence_size(sequence, size)
      (sequence.length >= size) || raise(Error, "Invalid LDAP result length. #{sequence}")
    end

    def set_result(sequence)
      # @ldap_result = {
      #   resultCode:   sequence[0],
      #   matchedDN:    sequence[1],
      #   errorMessage: sequence[2]
      # }

      # @res[:code], @res[:dn], @res[:error] = sequence

      @ldap_result[:resultCode]   = sequence[0]
      @ldap_result[:matchedDN]    = sequence[1]
      @ldap_result[:errorMessage] = sequence[2]
    end

    def decode_result
      @result_symbol, @message, @info, @flag = BER.lookup(:result, result_code)
    end

    def pdu_type
      BER.lookup(:pdu, @app_tag) || raise(Error, "Unknown pdu_type: #{@app_tag}")
    end

    # @example
    #   sequence =>
    #       [
    #         'uid=test1,ou=users,dc=example,dc=com',
    #         [
    #           [ 'mail',         [] ],
    #           [ 'givenName',    [] ],
    #           [ 'sn',           [] ],
    #           [ 'cn',           [] ],
    #           [ 'objectClass',  [] ],
    #           [ 'gidNumber',    [] ],
    #           [ 'uidNumber',    [] ],
    #           [ 'userPassword', [] ],
    #           [ 'uid',          [] ]
    #         ]
    #       ]
    #
    # @param sequence [Array]
    #
    def parse_search_return(sequence)
      check_sequence_size(sequence, 2)
      set_result(sequence)
      # @res[:code], @res[:dn], @res[:error] = sequence
      decode_result
      @search_entry = Struct.new(*sequence)
    end

    def parse_ldap_result(sequence)
      check_sequence_size(sequence, 3)
      set_result(sequence)
      decode_result
      parse_search_referral(sequence[3]) if referral?
    end

    def parse_extended_response(sequence)
      check_sequence_size(sequence, 3)
      set_result(sequence)
      decode_result
      @extended_response = sequence[3]
    end

    def parse_bind_response(sequence)
      check_sequence_size(sequence, 3)
      parse_ldap_result(sequence)
      @ldap_result[:serverSaslCreds] = sequence[3] if sequence.length >= 4
      result
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
      binding.pry
      s = OpenStruct.new
      s.base_object,
      s.scope,
      s.deref_aliases,
      s.size_limit,
      s.time_limit,
      s.types_only,
      s.filter,
      s.attributes = sequence
      @search_parameters = s
    end

    def parse_bind_request(sequence)
      s = OpenStruct.new
      s.version,
      s.name,
      s.authentication = sequence
      @bind_parameters = s
    end

    def parse_unbind_request(_sequence)
      nil
    end
  end
end
