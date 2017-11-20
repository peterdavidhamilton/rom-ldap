require 'ber'
require 'rom/ldap/types'
require 'rom/initializer'
module ROM
  module LDAP
    class Schema
      #
      # ATTRIBUTE TYPE
      #
      # An attribute type is a schema element that correlates an OID and a set of
      # names with an attribute syntax and a set of matching rules.
      #
      # The components of an attribute type definition include:
      #
      # - An OID used to uniquely identify the attribute type.
      # - A set of zero or more names that can be used to more easily reference the attribute type.
      # - An optional equality matching rule that specifies how equality matching
      #   should be performed on values of that attribute.
      #   If no equality matching rule is specified, then the default equality rule
      #   for the associated attribute syntax will be used.
      #   If the associated syntax doesn't have a default equality matching rule,
      #   then equality operations will not be allowed for that attribute.
      # - An optional ordering matching rule that specifies how ordering operations
      #   should be performed on values of that attribute.
      #   If no ordering matching rule is specified, then the default ordering rule
      #   for the associated attribute syntax will be used.
      #   If the associated syntax doesn't have a default ordering matching rule,
      #   then ordering operations will not be allowed for that attribute.
      # - An optional substring matching rule that specifies how substring matching
      #   should be performed on values of that attribute.
      #   If no substring matching rule is specified, then the default substring rule
      #   for the associated attribute syntax will be used.
      #   If the associated syntax doesn't have a default substring matching rule,
      #   then substring operations will not be allowed for that attribute.
      # - An optional syntax OID that specifies the syntax for values of the attribute.
      #   If no syntax is specified, then it will default to the directory string syntax.
      # - A flag that indicates whether the attribute is allowed to have multiple values.
      # - An optional attribute usage string indicating the context in which the attribute is to be used.
      # - An optional flag that indicates whether the attribute can be modified by external clients.
      #
      # @see Directory.parse_attribute_type
      #
      # @see <https://docs.oracle.com/cd/E19450-01/820-6173/def-attribute-type.html>
      #
      # @api private
      class TypeBuilder

        # @param attribute_name [String, Symbol]
        #
        # @param schema [Schema] Relation schema object.
        #
        def call(attribute_name, schema)
          attribute = Functions[:find_attr].call(attribute_name)
          multiple  = !attribute[:single]
          primitive = map_type(attribute)
          ruby_type = Types.const_get(primitive)
          read_type = if multiple
                        Types::Multiple.const_get(primitive)
                      else
                        Types::Single.const_get(primitive)
                      end

          ruby_type.meta(
            name:     attribute_name,
            source:   schema,
            multiple: multiple,
            read:     read_type,
            **extract_meta(attribute)
          )
        end

        private

        # Hash#slice alternative, will be available from Ruby release 2.5.0.
        #
        def extract_meta(attribute)
          attribute.select do |k,_|
            %i[description original matcher oid].include?(k)
          end
        end


        # @return [String]
        #
        # @api private
        def map_type(attribute)
          case attribute[:matcher]
          when 'booleanMatch'
            'Bool'
          when 'integerMatch', 'integerOrderingMatch'
            'Int'
          when 'generalizedTimeMatch', 'generalizedTimeOrderingMatch'
            'Time'
          when nil
            type = attribute[:single] ? 'String' : 'Array'

            ::BER.lookup(:oid, attribute[:oid]) || type
          when *STRING_MATCHERS then 'String'
          else
            puts "#{self.class}##{__callee__} #{attribute[:matcher]} not known"
            'Array'
          end
        end
      end
    end
  end
end
