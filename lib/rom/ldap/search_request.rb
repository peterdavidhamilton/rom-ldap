using ::BER

require 'rom/ldap/types'
require 'rom/ldap/expression'

module ROM
  module LDAP
    # The Search request is defined as follows:
    #
    #       SearchRequest ::= [APPLICATION 3] SEQUENCE {
    #            baseObject      LDAPDN,
    #            scope           ENUMERATED {
    #                 baseObject              (0),
    #                 singleLevel             (1),
    #                 wholeSubtree            (2),
    #                 ...  },
    #            derefAliases    ENUMERATED {
    #                 neverDerefAliases       (0),
    #                 derefInSearching        (1),
    #                 derefFindingBaseObj     (2),
    #                 derefAlways             (3) },
    #            sizeLimit       INTEGER (0 ..  maxInt),
    #            timeLimit       INTEGER (0 ..  maxInt),
    #            typesOnly       BOOLEAN,
    #            filter          Filter,
    #            attributes      AttributeSelection }
    #
    #       AttributeSelection ::= SEQUENCE OF selector LDAPString
    #                       -- The LDAPString is constrained to
    #                       -- <attributeSelector> in Section 4.5.1.8
    #
    #       Filter ::= CHOICE {
    #            and             [0] SET SIZE (1..MAX) OF filter Filter,
    #            or              [1] SET SIZE (1..MAX) OF filter Filter,
    #            not             [2] Filter,
    #            equalityMatch   [3] AttributeValueAssertion,
    #            substrings      [4] SubstringFilter,
    #            greaterOrEqual  [5] AttributeValueAssertion,
    #            lessOrEqual     [6] AttributeValueAssertion,
    #            present         [7] AttributeDescription,
    #            approxMatch     [8] AttributeValueAssertion,
    #            extensibleMatch [9] MatchingRuleAssertion,
    #            ...  }
    #
    #       SubstringFilter ::= SEQUENCE {
    #            type           AttributeDescription,
    #            substrings     SEQUENCE SIZE (1..MAX) OF substring CHOICE {
    #                 initial [0] AssertionValue,  -- can occur at most once
    #                 any     [1] AssertionValue,
    #                 final   [2] AssertionValue } -- can occur at most once
    #            }
    #
    #       MatchingRuleAssertion ::= SEQUENCE {
    #            matchingRule    [1] MatchingRuleId OPTIONAL,
    #            type            [2] AttributeDescription OPTIONAL,
    #            matchValue      [3] AssertionValue,
    #            dnAttributes    [4] BOOLEAN DEFAULT FALSE }
    #
    #
    #
    #
    # @see https://tools.ietf.org/html/rfc4511#section-4.5.1
    #
    # @api private
    class SearchRequest

      extend Initializer

      # @see https://tools.ietf.org/html/rfc4511#section-4.5.1.7
      #
      # @!attribute [r] expression
      #   @return [Expression] Required.
      option :expression, type: Types.Instance(Expression)

      # @see https://tools.ietf.org/html/rfc4511#section-4.5.1.1
      #
      # @!attribute [r] base
      #   @return [String] Set to Relation default_base:
      option :base, proc(&:to_s), type: Types::DN, default: -> { EMPTY_STRING }

      # Defaults to only searching entries under base object.
      #
      # @see https://tools.ietf.org/html/rfc4511#section-4.5.1.2
      #
      # @!attribute [r] scope
      #   @return [Integer]
      option :scope, type: Types::Scope, default: -> { SCOPE_SUB }

      # Defaults to dereferencing both when searching and when locating the search base.
      #
      # @see https://tools.ietf.org/html/rfc4511#section-4.5.1.3
      #
      # @!attribute [r] deref
      #   @return [Integer]
      option :deref, type: Types::Deref, default: -> { DEREF_ALWAYS }

      # Defaults to all attributes '*' but not operational.
      #
      # @see https://tools.ietf.org/html/rfc4511#section-4.5.1.8
      #
      # @!attribute [r] attributes
      #   @return [Array<String>] Restrict attributes returned.
      option :attributes, type: Types::Strings, default: -> { [WILDCARD] }

      # @see https://tools.ietf.org/html/rfc4511#section-4.5.1.6
      #
      # @!attribute [r] attributes_only
      #   @return [TrueClass, FalseClass] Do not include values.
      option :attributes_only, type: Types::Strict::Bool, default: -> { false }

      # @!attribute [r] reverse
      #   @return [TrueClass, FalseClass]
      option :reverse, type: Types::Strict::Bool, default: -> { false }

      # Defaults to not paging results
      #
      # Adds :paged_result control to the request.
      #
      # @!attribute [r] paged
      #   @return [TrueClass, FalseClass]
      option :paged, type: Types::Strict::Bool, default: -> { false }

      # ads-maxTimeLimit: 15000
      # Defaults to zero, no timeout.
      #
      # @see https://tools.ietf.org/html/rfc4511#section-4.5.1.5
      #
      # @!attribute [r] timeout
      #   @return [Integer]
      option :timeout, type: Types::Strict::Integer, default: -> { 0 }

      # ads-maxSizeLimit: 200
      #
      # @see https://tools.ietf.org/html/rfc4511#section-4.5.1.4
      #
      # @!attribute [r] max
      #   @return [Integer]
      option :max, type: Types::Strict::Integer, optional: true

      # @!attribute [r] sort
      #   @return [Array<String>]
      option :sorted, type: Types::Strict::Array, optional: true

      # Search request components.
      #
      # @return [Array]
      def parts
        [
          base.to_ber,                  # 4.5.1.1.  SearchRequest.baseObject
          scope.to_ber_enumerated,      # 4.5.1.2.  SearchRequest.scope
          deref.to_ber_enumerated,      # 4.5.1.3.  SearchRequest.derefAliases
          limit.to_ber,                 # 4.5.1.4.  SearchRequest.sizeLimit
          timeout.to_ber,               # 4.5.1.5.  SearchRequest.timeLimit
          attributes_only.to_ber,       # 4.5.1.6.  SearchRequest.typesOnly
          expression.to_ber,            # 4.5.1.7.  SearchRequest.filter
          ber_attrs.to_ber_sequence     # 4.5.1.8.  SearchRequest.attributes
        ]
      end

      #
      # Controls sent by clients are termed 'request controls', and those
      #   sent by servers are termed 'response controls'.
      #
      #        Controls ::= SEQUENCE OF control Control
      #
      #        Control ::= SEQUENCE {
      #             controlType             LDAPOID,
      #             criticality             BOOLEAN DEFAULT FALSE,
      #             controlValue            OCTET STRING OPTIONAL }
      #
      #
      # @see https://tools.ietf.org/html/rfc4511#section-4.1.11
      #
      # @return [Array]
      def controls
        ctrls = []
        ctrls << build_controls(:paged_results, cookie)    if paged
        ctrls << build_controls(:sort_request, sort_rules) if sorted
        ctrls.empty? ? nil : ctrls.to_ber_contextspecific(0)
      end

      private

      # Set test server to only serve 200 at a time to check paging
      #
      # Limit to no more than 126 entries.
      #
      # @return [Integer]
      #
      # @api private
      def limit
        (0..126).cover?(max) ? max : 0
      end

      # @return [Array]
      #
      # @api private
      def ber_attrs
        Array(attributes).map { |attr| attr.to_s.to_ber }
      end

      # @see https://tools.ietf.org/html/rfc2696
      #
      # @return [Array]
      #
      # @api private
      def cookie
        [126.to_ber, EMPTY_STRING.to_ber]
        # [99.to_ber, EMPTY_STRING.to_ber]
      end

      #       Control ::= SEQUENCE {
      #         controlType             LDAPOID,
      #         criticality             BOOLEAN DEFAULT FALSE,
      #         controlValue            OCTET STRING OPTIONAL }
      #
      # @return [String] LDAP 'control'
      #
      # @see PDU#result_controls
      #
      def build_controls(type, payload)
        [
          OID[type].to_ber,
          false.to_ber,
          payload.to_ber_sequence.to_s.to_ber
        ].to_ber_sequence
      end

      # Only uses attribute names because not all vendors have fully implemented SSS.
      #
      #       SortKeyList ::= SEQUENCE OF SEQUENCE {
      #            attributeType   AttributeDescription,
      #            orderingRule    [0] MatchingRuleId OPTIONAL,
      #            reverseOrder    [1] BOOLEAN DEFAULT FALSE }
      #
      #
      # @see https://tools.ietf.org/html/rfc2891
      # @see https://docs.ldap.com/ldap-sdk/docs/javadoc/com/unboundid/ldap/sdk/controls/ServerSideSortRequestControl.html
      #
      # @api private
      def sort_rules
        sorted.map { |attr| [attr.to_ber].to_ber_sequence }
      end

    end
  end
end
