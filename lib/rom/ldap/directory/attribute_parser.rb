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
