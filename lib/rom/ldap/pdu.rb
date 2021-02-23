# frozen_string_literal: true

require 'ostruct'
require 'dry/core/class_attributes'
require 'rom/initializer'

module ROM
  module LDAP
    # @see PDU
    #
    # @return [Array<Symbol>]
    #
    SUCCESS_CODES = %i[
      success
      time_limit_exceeded
      size_limit_exceeded
      compare_true
      compare_false
      referral
      sasl_bind_in_progress
    ].freeze

    # LDAP Message Protocol Data Unit (PDU)
    #
    # @api private
    class PDU

      extend Initializer

      param :message_id, proc(&:to_i), reader: true, type: Types::Strict::Integer

      # @!attribute [r] tag
      #   @return [Array]
      param :tag, reader: :private, type: Types::Strict::Array

      param :ctrls, reader: :private, type: Types::Strict::Array, default: -> { EMPTY_ARRAY }

      # @return [Integer]
      #
      def app_tag
        tag.ber_identifier & 0x1f
      end

      # @return [Integer]
      #
      def result_code
        tag[0]
      end

      #
      # @return [String]
      #
      def matched_dn
        tag[1]
      end

      # @example
      #   "Matchingrule is required for sorting by the attribute cn"
      #
      # @return [String]
      #
      def advice
        tag[2]
      end

      def search_referrals
        return unless search_referral?

        tag[3] || EMPTY_ARRAY
      end

      def result_server_sasl_creds
        return unless bind_result? && gteq4?

        tag[3]
      end

      # @return [Array] => [version, username, password]
      #
      #
      def bind_result
        return unless bind_result?
        raise ResponseTypeInvalidError, 'Invalid bind_result' unless gteq_3?

        tag
      end

      #
      # @return [OpenStruct] => :version, :name, :authentication
      #
      def bind_parameters
        return unless bind_request?

        s = ::OpenStruct.new
        s.version, s.name, s.authentication = tag
        s
      end

      #
      # @return [OpenStruct, NilClass] => :version, :name, :authentication
      #
      def search_parameters
        return unless search_request?

        s = ::OpenStruct.new
        s.base_object,
        s.scope,
        s.deref_aliases,
        s.size_limit,
        s.time_limit,
        s.types_only,
        s.filter,
        s.attributes = tag
        s
      end

      # Message
      #
      # @example => "No attribute with the name false exists in the server's schema"
      #
      # @return [String, NilClass]
      #
      def extended_response
        raise ResponseTypeInvalidError, 'Invalid extended_response' unless gteq_3?

        tag[3] if extended_response?
      end

      # ["dn", [ entry... ]]
      #
      # @return [Array, NilClass]
      #
      def search_entry
        raise ResponseTypeInvalidError, 'Invalid search_entry' unless gteq_2?

        tag if search_result?
      end

      # RFC-2251, an LDAP 'control' is a sequence of tuples, each consisting of
      #   - an OID
      #   - a boolean criticality flag defaulting FALSE
      #   - and an optional Octet String
      #
      # If only two fields are given, the second one may be either criticality
      # or data, since criticality has a default value. RFC-2696 is a good example.
      #
      # @see Connection::Read#search
      #
      # @return [Array<OpenStruct>] => :oid, :criticality, :value
      #
      def result_controls
        ctrls.map do |control|
          oid, level, value = control
          value, level = level, false if level.is_a?(String)
          ::OpenStruct.new(oid: oid, criticality: level, value: value)
        end
      end

      # logging =======================  #

      # First item from responses.yaml
      #
      # @return [String]
      #
      def message
        detailed_response[0]
      end

      # Grep for error message
      #
      # @return [String, FalseClass]
      #
      def error_message
        tag[3][/comment: (.*), data/, 1] if tag[3]
      end

      # @return [String]
      #
      def info
        detailed_response[1]
      end

      # @return [String]
      #
      def flag
        detailed_response[2]
      end

      # predicates =======================  #

      # @return [Boolean]
      #
      def add_response?
        pdu_type == :add_response
      end

      # @see https://tools.ietf.org/html/rfc4511#section-4.2.1
      #
      # @return [Boolean]
      #
      def bind_request?
        pdu_type == :bind_request
      end

      # A successful operation is indicated by a BindResponse with a resultCode set to success.
      #
      # @see https://tools.ietf.org/html/rfc4511#section-4.2.2
      #
      # @return [Boolean]
      #
      def bind_result?
        pdu_type.eql?(:bind_result)
      end

      # @return [Boolean]
      #
      def search_request?
        pdu_type.eql?(:search_request)
      end

      # @return [Boolean]
      #
      def search_result?
        pdu_type.eql?(:search_returned_data)
      end

      # @return [Boolean]
      #
      def search_referral?
        pdu_type == :search_result_referral
      end

      # @return [Boolean]
      #
      def extended_response?
        pdu_type == :extended_response
      end

      # @return [Boolean]
      #
      def success?
        SUCCESS_CODES.include?(result_code_symbol)
      end

      # @return [Boolean]
      #
      def failure?
        !success?
      end

      # conversion =======================  #

      # @return [Symbol]
      #
      def pdu_type
        BER.fetch(:response, app_tag) || raise(ResponseTypeInvalidError, "Unknown pdu_type: #{app_tag}")
      end

      # @return [Symbol]
      #
      def result_code_symbol
        BER.fetch(:result, result_code)
      end

      private

      def detailed_response
        RESPONSES[result_code_symbol]
      end

      # @return [Boolean]
      #
      def gteq_2?
        tag.length >= 2
      end

      # @return [Boolean]
      #
      def gteq_3?
        tag.length >= 3
      end

    end
  end
end
