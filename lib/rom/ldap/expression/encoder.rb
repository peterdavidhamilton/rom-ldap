using ::BER

require 'dry/initializer'

module ROM
  module LDAP
    class Expression
      # Used in ROM::LDAP::Expression#to_ber to encode op, left, right.
      #
      # Filter ::=
      #     CHOICE {
      #         and             [0] SET OF Filter,
      #         or              [1] SET OF Filter,
      #         not             [2] Filter,
      #         equalityMatch   [3] AttributeValueAssertion,
      #         substrings      [4] SubstringFilter,
      #         greaterOrEqual  [5] AttributeValueAssertion,
      #         lessOrEqual     [6] AttributeValueAssertion,
      #         present         [7] AttributeType,
      #         approxMatch     [8] AttributeValueAssertion,
      #         extensibleMatch [9] MatchingRuleAssertion
      #     }
      #
      # SubstringFilter ::=
      #     SEQUENCE {
      #         type               AttributeType,
      #         SEQUENCE OF CHOICE {
      #             initial        [0] LDAPString,
      #             any            [1] LDAPString,
      #             final          [2] LDAPString
      #         }
      #     }
      #
      # MatchingRuleAssertion ::=
      #     SEQUENCE {
      #       matchingRule    [1] MatchingRuleId OPTIONAL,
      #       type            [2] AttributeDescription OPTIONAL,
      #       matchValue      [3] AssertionValue,
      #       dnAttributes    [4] BOOLEAN DEFAULT FALSE
      #     }
      #
      # Matching Rule Suffixes
      #     Less than   [.1] or .[lt]
      #     Less than or equal to  [.2] or [.lte]
      #     Equality  [.3] or  [.eq] (default)
      #     Greater than or equal to  [.4] or [.gte]
      #     Greater than  [.5] or [.gt]
      #     Substring  [.6] or  [.sub]
      #
      #
      # @api private
      class Encoder
        extend Dry::Initializer

        param :op
        param :left
        param :right

        def call
          case op

          when :op_eql
            if right == WILDCARD
              left.to_s.to_ber_contextspecific(7)

            elsif right =~ /[*]/ # substring

              ary = right.split(/[*]+/, -1)

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
              seq.unshift first if first
              seq.push last if last

              [left.to_s.to_ber, seq.to_ber].to_ber_contextspecific(4)
            else
              # equality
              [left.to_s.to_ber, unescape(right).to_ber].to_ber_contextspecific(3)
            end

          # make sure data is not forced to UTF-8
          when :bineq
            [left.to_s.to_ber, unescape(right).to_ber_bin].to_ber_contextspecific(3)

          when :op_ext
            seq = []

            raise(Error, "Bad attribute #{left}") unless left =~ EXTENSIBLE_REGEX

            type = Regexp.last_match(1)
            dn   = Regexp.last_match(2)
            rule = Regexp.last_match(4)

            seq << rule.to_ber_contextspecific(1) unless rule.to_s.empty? # matchingRule
            seq << type.to_ber_contextspecific(2) unless type.to_s.empty? # type
            seq << unescape(right).to_ber_contextspecific(3)              # matchingValue
            seq << '1'.to_ber_contextspecific(4) unless dn.to_s.empty?    # dnAttributes

            seq.to_ber_contextspecific(9)

          when :op_gte
            [left.to_s.to_ber, unescape(right).to_ber].to_ber_contextspecific(5)

          when :op_lte
            [left.to_s.to_ber, unescape(right).to_ber].to_ber_contextspecific(6)

          when :con_and
            ary = [left.coalesce(:con_and), right.coalesce(:con_and)].flatten
            ary.map(&:to_ber).to_ber_contextspecific(0)

          when :con_or
            ary = [left.coalesce(:con_or), right.coalesce(:con_or)].flatten
            ary.map(&:to_ber).to_ber_contextspecific(1)

          when :con_not
            [left.to_ber].to_ber_contextspecific(2)

          # when :ne
          #   # TODO: negation of #eq method used
          #   binding.pry

          #   [self.class.eq(left, right).to_ber].to_ber_contextspecific(2)
          end
        end

        private

        # Converts escaped characters to unescaped characters
        #
        # @example
        #   => "\\28"
        #
        # @return [String]
        #
        # @api private
        def unescape(right)
          right.to_s.gsub(UNESCAPE_REGEX) { [Regexp.last_match(1).hex].pack('U') }
        end
      end
    end
  end
end