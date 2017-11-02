require 'rom/ldap/types'
require 'rom/initializer'

module ROM
  module LDAP
    class Schema
      # @api private
      class TypeBuilder
        extend Initializer

        param :attributes

        def call(attribute_name, schema)
          attribute = by_name(attribute_name) || EMPTY_HASH
          multiple  = !attribute[:single]
          primitive = map_type(attribute)
          ruby_type = Types.const_get(primitive)
          read_type = if multiple
                        Types::Multiple.const_get(primitive)
                      else
                        Types::Single.const_get(primitive)
                      end

          ruby_type.meta(
            name:         attribute_name,
            source:       schema,
            multiple:     multiple,
            description:  attribute[:description],
            matcher:      attribute[:matcher],
            oid:          attribute[:oid],
            read:         read_type
          )
        end

        private

        # @return [Hash]
        #
        # @api private
        def by_name(name)
          attributes.select { |a| a[:name].downcase.eql?(name) }.first
        end


        STRING_MATCHERS = %w[
                              caseIgnoreListMatch
                              caseIgnoreMatch
                              caseExactMatch
                              distinguishedNameMatch
                              objectIdentifierMatch
                              octetStringMatch
                              protocolInformationMatch
                              telephoneNumberMatch
                            ].freeze

        # @return [String]
        #
        # @api private
        def map_type(attribute)
          case attribute[:matcher]
          when *STRING_MATCHERS       then 'String'
          when 'booleanMatch'         then 'Bool'
          when 'integerMatch'         then 'Int'
          when 'generalizedTimeMatch' then 'Time'
          when nil
            type = attribute[:single] ? 'String' : 'Array'
            oids.fetch(attribute[:oid], type)
          else
            raise "#{self.class}##{__callee__} #{attribute[:matcher]} not known"
          end
        end

        # @return [Hash]
        #
        # @api private
        def oids
          @oids ||= ROM::LDAP.config[:oids]
        end
      end
    end
  end
end
