# frozen_string_literal: true

module ROM
  module LDAP
    module Parsers
      #
      # RFC4512 - 4.1.2.  Attribute Types
      #
      # @see https://tools.ietf.org/html/rfc4512#section-4.1.2
      #
      # Attribute Type definitions are written according to the ABNF:
      #
      #      AttributeTypeDescription = LPAREN WSP
      #          numericoid                    ; object identifier
      #          [ SP "NAME" SP qdescrs ]      ; short names (descriptors)
      #          [ SP "DESC" SP qdstring ]     ; description
      #          [ SP "OBSOLETE" ]             ; not active
      #          [ SP "SUP" SP oid ]           ; supertype
      #          [ SP "EQUALITY" SP oid ]      ; equality matching rule
      #          [ SP "ORDERING" SP oid ]      ; ordering matching rule
      #          [ SP "SUBSTR" SP oid ]        ; substrings matching rule
      #          [ SP "SYNTAX" SP noidlen ]    ; value syntax
      #          [ SP "SINGLE-VALUE" ]         ; single-value
      #          [ SP "COLLECTIVE" ]           ; collective
      #          [ SP "NO-USER-MODIFICATION" ] ; not user modifiable
      #          [ SP "USAGE" SP usage ]       ; usage
      #          extensions WSP RPAREN         ; extensions
      #
      #      usage = "userApplications"     /  ; user
      #              "directoryOperation"   /  ; directory operational
      #              "distributedOperation" /  ; DSA-shared operational
      #              "dSAOperation"            ; DSA-specific operational
      #
      #    where:
      #      <numericoid> is object identifier assigned to this attribute type;
      #      NAME <qdescrs> are short names (descriptors) identifying this
      #          attribute type;
      #      DESC <qdstring> is a short descriptive string;
      #      OBSOLETE indicates this attribute type is not active;
      #      SUP oid specifies the direct supertype of this type;
      #      EQUALITY, ORDERING, and SUBSTR provide the oid of the equality,
      #          ordering, and substrings matching rules, respectively;
      #      SYNTAX identifies value syntax by object identifier and may suggest
      #          a minimum upper bound;
      #      SINGLE-VALUE indicates attributes of this type are restricted to a
      #          single value;
      #      COLLECTIVE indicates this attribute type is collective
      #          [X.501][RFC3671];
      #      NO-USER-MODIFICATION indicates this attribute type is not user
      #          modifiable;
      #      USAGE indicates the application of this attribute type; and
      #      <extensions> describe extensions.
      #
      #
      # @param attribute [String]
      #   "( 0.9.2342.19200300.100.1.1 NAME ( 'uid' 'userid' )
      #   DESC 'RFC1274: user identifier' EQUALITY caseIgnoreMatch
      #   SUBSTR caseIgnoreSubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15
      #   USAGE userApplications X-SCHEMA 'core' )"
      #
      # @return [Array<Hash>] Alternative names return multiple hashes
      #
      # @example
      #   Parsers::Attribute.new("( NAME cn....)").call
      #
      # @api private
      class Attribute

        extend Initializer

        param :attribute, type: Types::Strict::String, reader: :private

        def call
          Array(canonical_names).map do |original_name|
            {
              name:         LDAP.formatter[original_name],
              definition:   attribute,
              canonical:    original_name,
              description:  description,
              oid:          attribute_oid,
              syntax:       syntax_oid,
              single:       single_value?,
              editable:     editable?,
              schema:       schema,
              draft:        draft,

              # super_type: [ SP "SUP" SP oid ]
              # collective: [ SP "COLLECTIVE" ]

              rules: {
                approx:           approx_matcher,
                equality:         equality_matcher,
                substr:           sub_string_rule,
                ordering:         ordering_rule,
                min_value_count:  min_value_count,
                max_value_count:  max_value_count,
                min_value_length: min_value_length,
                max_value_length: max_value_length,
                min_int_value:    min_int_value,
                max_int_value:    max_int_value,
                allowed_value:    allowed_value
              }
            }
          end
        end

        private

        # short names (descriptors)
        #
        # @return [Array<String>] => ['uid', 'userid']
        #
        def canonical_names
          if attribute[/NAME '(\S+)'/]
            Regexp.last_match(1)
          elsif attribute[/NAME \( '(\S+)' '(\S+)' \)/]
            [Regexp.last_match(1), Regexp.last_match(2)]
          end
        end

        # numericoid
        #
        # @return [String]
        #
        def attribute_oid
          attribute[/^\( ([\d\.]*)/, 1]
        end

        # @return [Boolean]
        #
        def editable?
          modifiable? and public?
        end

        # not user modifiable
        #
        # @return [Boolean]
        #
        def modifiable?
          attribute.scan(/NO-USER-MODIFICATION/).none?
        end

        # value syntax
        #
        # @return [String]
        #
        def syntax_oid
          attribute[/SYNTAX (\S+)/, 1].to_s.tr("'", '')
        end

        # userApplications
        #
        # @return [Boolean]
        #
        def public?
          attribute[/USAGE (\S+)/, 1] == 'userApplications'
        end

        # directoryOperation
        # distributedOperation
        # dSAOperation
        #
        # @return [Boolean]
        #
        def private?
          attribute[/USAGE (\S+)/, 1] != 'userApplications'
        end

        # An optional human-readable description, which should be enclosed in single quotation marks.
        #
        # @return [String]
        #
        def description
          attribute[/DESC '(.+)' [A-Z]+\s/, 1]
        end

        # ordering matching rule
        #
        # @return [String]
        #
        def ordering_rule
          attribute[/ORDERING (\S+)/, 1]
        end

        # @return [String]
        #
        def sub_string_rule
          attribute[/SUBSTR (\S+)/, 1]
        end

        # single-value
        #
        # @return [Boolean]
        #
        def single_value?
          attribute.scan(/SINGLE-VALUE/).any?
        end

        # @return [String]
        #
        def equality_matcher
          attribute[/EQUALITY (\S+)/, 1]
        end

        # ================================
        #
        # Extended Attribute Flags
        #
        # ================================

        # Provides information about where the attribute type is defined,
        #   either by a particular RFC or Internet Draft or within the project.
        #
        def draft
          attribute[/X-ORIGIN '(\S+)'/, 1]
        end

        # @return [String] Name of defining schema
        #
        def schema
          attribute[/X-SCHEMA '(\S+)'/, 1]
        end

        # Indicates which approximate matching rule should be used for the attribute type. If this is specified, then its value should be the name or OID of a registered approximate matching rule.
        # Specifies the name or OID of the approximate matching rule that should be
        #   used in conjunction with the specified attribute Type.
        #
        # @see https://ldapwiki.com/wiki/ApproxMatch
        #
        def approx_matcher
          attribute[/X-APPROX (\S+)/, 1]
        end

        # Specifies the set of values that attributes of that type will be allowed to have.
        #
        def allowed_value
          attribute[/X-ALLOWED-VALUE (\S+)/, 1]
        end

        # Provides one or more regular expressions that describe acceptable values for the associated attribute.
        # Values will only be allowed if they match at least one of the regular expressions.
        #
        def value_regex
          attribute[/X-VALUE-REGEX (\S+)/, 1]
        end

        # Specifies the minimum number of characters that values of the associated
        #   attribute are permitted to have.
        #
        def min_value_length
          attribute[/X-MIN-VALUE-LENGTH (\d+)/, 1].to_i
        end

        # Specifies the maximum number of characters that values of the associated
        #   attribute are permitted to have.
        #
        def max_value_length
          attribute[/X-MAX-VALUE-LENGTH (\d+)/, 1].to_i
        end

        # Specifies the minimum integer value that may be assigned to the associated attribute.
        #
        def min_int_value
          attribute[/X-MIN-INT-VALUE (\d+)/, 1].to_i
        end

        # Specifies the maximum integer value that may be assigned to the associated attribute.
        #
        def max_int_value
          attribute[/X-MAX-INT-VALUE (\d+)/, 1].to_i
        end

        # Specifies the minimum number of values that the attribute is allowed
        #   to have in any entry.
        #
        def min_value_count
          attribute[/X-MIN-VALUE-COUNT (\d+)/, 1].to_i
        end

        # Specifies the maximum number of values that the attribute is allowed
        #   to have in any entry.
        #
        def max_value_count
          attribute[/X-MAX-VALUE-COUNT (\d+)/, 1].to_i
        end

      end
    end
  end
end
