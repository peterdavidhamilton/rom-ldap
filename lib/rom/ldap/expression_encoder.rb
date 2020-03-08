# frozen_string_literal: true

module ROM
  module LDAP
    # Used in ROM::LDAP::Expression#to_ber.
    #
    #       Filter ::=
    #           CHOICE {
    #               and             [0] SET OF Filter,
    #               or              [1] SET OF Filter,
    #               not             [2] Filter,
    #               equalityMatch   [3] AttributeValueAssertion,
    #               substrings      [4] SubstringFilter,
    #               greaterOrEqual  [5] AttributeValueAssertion,
    #               lessOrEqual     [6] AttributeValueAssertion,
    #               present         [7] AttributeType,
    #               approxMatch     [8] AttributeValueAssertion,
    #               extensibleMatch [9] MatchingRuleAssertion
    #           }
    #
    #       SubstringFilter ::=
    #           SEQUENCE {
    #               type               AttributeType,
    #               SEQUENCE OF CHOICE {
    #                   initial        [0] LDAPString,
    #                   any            [1] LDAPString,
    #                   final          [2] LDAPString
    #               }
    #           }
    #
    #       MatchingRuleAssertion ::=
    #           SEQUENCE {
    #             matchingRule    [1] MatchingRuleId OPTIONAL,
    #             type            [2] AttributeDescription OPTIONAL,
    #             matchValue      [3] AssertionValue,
    #             dnAttributes    [4] BOOLEAN DEFAULT FALSE
    #           }
    #
    #       Matching Rule Suffixes
    #           Less than   [.1] or .[lt]
    #           Less than or equal to  [.2] or [.lte]
    #           Equality  [.3] or  [.eq] (default)
    #           Greater than or equal to  [.4] or [.gte]
    #           Greater than  [.5] or [.gt]
    #           Substring  [.6] or  [.sub]
    #
    #
    # @api private
    class ExpressionEncoder

      using ::BER

      extend Initializer

      option :op, type: Types::Abstract

      option :field, optional: true, type: Types::Field
      option :value, optional: true, type: Types::Value
      option :exps,  optional: true, type: Types::Array.of(Types.Instance(LDAP::Expression))

      # @return [BER]
      #
      def call
        case op
        when :op_eql
          if value == WILDCARD
            field.to_s.to_ber_contextspecific(7)
          elsif /[*]/.match?(value.to_s) # substring
            substring
          else
            to_context(3)
          end
        when :op_bineq
          [
            field.to_s.to_ber,
            unescape(value).to_ber_bin
          ].to_ber_contextspecific(3)
        when :op_ext
          extensible
        when :op_gte
          to_context(5)
        when :op_lte
          to_context(6)
        when :op_prx
          to_context(8)
        when :con_and
          exps.map(&:to_ber).to_ber_contextspecific(0)
        when :con_or
          exps.map(&:to_ber).to_ber_contextspecific(1)
        when :con_not
          exps.map(&:to_ber).to_ber_contextspecific(2)
        end
      end

      private

      def substring
        ary = value.split(/[*]+/, -1)

        if ary.first.empty?
          first = nil
          ary.shift
        else
          first = unescape(ary.shift).to_ber_contextspecific(0)
        end

        if ary.last.empty?
          last = nil
          ary.pop
        else
          last = unescape(ary.pop).to_ber_contextspecific(2)
        end

        seq = ary.map { |e| unescape(e).to_ber_contextspecific(1) }
        seq.unshift(first) if first
        seq.push(last) if last

        [
          field.to_s.to_ber,
          seq.to_ber
        ].to_ber_contextspecific(4)
      end

      def extensible
        raise(Error, "Bad attribute #{field}") unless field =~ EXTENSIBLE_REGEX

        type = Regexp.last_match(1)
        dn   = Regexp.last_match(2)
        rule = Regexp.last_match(4)

        seq = []
        seq << rule.to_ber_contextspecific(1) unless rule.to_s.empty? # matchingRule
        seq << type.to_ber_contextspecific(2) unless type.to_s.empty? # type
        seq << unescape(value).to_ber_contextspecific(3)              # matchingValue
        seq << '1'.to_ber_contextspecific(4) unless dn.to_s.empty?    # dnAttributes

        seq.to_ber_contextspecific(9)
      end

      # Common BER encoding
      #
      # @return [String]
      #
      def to_context(int)
        [
          field.to_s.to_ber,
          unescape(value).to_ber
        ].to_ber_contextspecific(int)
      end

      # @note
      #   Don't attempt to unescape 16 byte binary data assumed to be objectGUIDs.
      #   The binary form of 5936AE79-664F-44EA-BCCB-5C39399514C6
      #   triggers a BINARY -> UTF-8 conversion error.
      #
      # Converts escaped characters to unescaped characters
      #
      # @example
      #   => "\\28"
      #
      # @return [String]
      #
      # @api private
      def unescape(str)
        if str.to_s.length.eql?(16) && str.to_s.encoding.eql?(Encoding::BINARY)
          str
        else
          str.to_s.gsub(UNESCAPE_REGEX) { [Regexp.last_match(1).hex].pack('U') }
        end
      end

    end
  end
end
