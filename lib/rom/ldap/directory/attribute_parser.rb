module ROM
  module LDAP
    class Directory
      # Build hashes from attribute definitions.
      #
      # @see https://ldapwiki.com/wiki/Extended%20Flags
      #
      # @return [Array<Hash>] Parsed array of all directory attributes.
      #
      # @example
      #   [{
      #            :name => "cn",
      #        :original => "cn",
      #     :description => "RFC2256: common name(s) for which the entity is known by",
      #             :oid => "1.3.6.1.4.1.1466.115.121.1.15",
      #         :matcher => "caseIgnoreMatch",
      #          :substr => "caseIgnoreSubstringsMatch",
      #        :ordering => nil,
      #          :single => false,
      #      :modifiable => false,
      #           :usage => "userApplications",
      #          :source => "system"
      #   }]
      #
      class AttributeParser

        extend Initializer

        param :attribute, reader: :private

        #
        # @param attribute [String]
        #   "( 0.9.2342.19200300.100.1.1 NAME ( 'uid' 'userid' )
        #   DESC 'RFC1274: user identifier' EQUALITY caseIgnoreMatch
        #   SUBSTR caseIgnoreSubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15
        #   USAGE userApplications X-SCHEMA 'core' )"
        #
        # @return [Array<Hash>] Alternative names return multiple hashes
        #
        # @see TypeBuilder
        #
        # @api public
        def call
          Array(original_names).map do |original_name|
            {
              name:        Entry.rename(original_name),
              original:    original_name,
              description: description,
              oid:         object_identifier,
              matcher:     equality_matcher,
              substr:      attribute[/SUBSTR (\S+)/, 1],
              ordering:    attribute[/ORDERING (\S+)/, 1],
              single:      single_value?,
              modifiable:  modifiable?,
              usage:       attribute[/USAGE (\S+)/, 1],
              source:      source_schema
            }
          end
        end


        def modifiable?
          attribute.scan(/NO-USER-MODIFICATION/).any?
        end

        def object_identifier
          attribute[/SYNTAX (\S+)/, 1].to_s.tr("'", '')
        end

        def description
          attribute[/DESC '(.+)' [A-Z]+/, 1]
        end

        # @return [Boolean]
        #
        def single_value?
          attribute.scan(/SINGLE-VALUE/).any?
        end

        # @return [String] Name of defining schema
        #
        def source_schema
          attribute[/X-SCHEMA '(\S+)'/, 1]
        end

        # @return [Array<String>] => ['uid', 'userid']
        #
        def original_names
          if attribute[/NAME '(\S+)'/, 1]
            attribute[/NAME '(\S+)'/, 1]
          elsif attribute[/NAME \( '(\S+)' '(\S+)' \)/]
            [
              Regexp.last_match(1),
              Regexp.last_match(2)
            ]
          end
        end


        def equality_matcher
          attribute[/EQUALITY (\S+)/, 1]
        end


        # https://ldapwiki.com/wiki/ApproxMatch
        #
        def equality_matcher
          attribute[/X-APPROX (\S+)/, 1]
        end
      end
    end
  end
end






#   # Build hash from attribute definition.
#   #
#   # @example
#   #   parse_attribute_type("...")
#   #     #=> { name: :uidnumber, description: '', single: true)
#   #
#   # @param type [String]
#   #
#   # @return [Hash]
#   #
#   # @see TypeBuilder
#   #
#   # @api private
#   def parse_attribute_type(type)
#     attribute_names =
#       if type[/NAME '(\S+)'/, 1]
#         type[/NAME '(\S+)'/, 1]
#       elsif type[/NAME \( '(\S+)' '(\S+)' \)/]
#         [Regexp.last_match(1), Regexp.last_match(2)]
#       end

# # Attribute Type Description Format - RFC4512
# #
# # https://docs.oracle.com/cd/E19476-01/821-0509/attribute-type-description-format.html
# #
# # oid:     type[/^\(\s*([\d\.]*)/, 1],
# # rfc4512: type
# # https://ping.force.com/Support/PingIdentityArticle?id=kA340000000PMwQCAW
# #
# #
# # X-ALLOWED-VALUE — Provides an explicit set of values that are the only values that will be allowed for the associated attribute.
# # X-VALUE-REGEX — Provides one or more regular expressions that describe acceptable values for the associated attribute. Values will only be allowed if they match at least one of the regular expressions.
# # X-MIN-VALUE-LENGTH — Specifies the minimum number of characters that values of the associated attribute are permitted to have.
# # X-MAX-VALUE-LENGTH — Specifies the maximum number of characters that values of the associated attribute are permitted to have.
# # X-MIN-INT-VALUE — Specifies the minimum integer value that may be assigned to the associated attribute.
# # X-MAX-INT-VALUE — Specifies the maximum integer value that may be assigned to the associated attribute.
# # X-MIN-VALUE-COUNT — Specifies the minimum number of values that the attribute is allowed to have in any entry.
# # X-MAX-VALUE-COUNT — Specifies the maximum number of values that the attribute is allowed to have in any entry.

#     Array(attribute_names).map do |name|
#       {
#         name:        Entry.rename(name), # canonical
#         original:    name,               # source
#         description: type[/DESC '(.+)' [A-Z]+/, 1],
#         oid:         type[/SYNTAX (\S+)/, 1].to_s.tr("'", ''),
#         matcher:     type[/EQUALITY (\S+)/, 1],
#         substr:      type[/SUBSTR (\S+)/, 1],
#         ordering:    type[/ORDERING (\S+)/, 1],
#         single:      type.scan(/SINGLE-VALUE/).any?,
#         modifiable:  type.scan(/NO-USER-MODIFICATION/).any?,
#         usage:       type[/USAGE (\S+)/, 1],
#         source:      type[/X-SCHEMA '(\S+)'/, 1]
#       }
#     end
#   end
