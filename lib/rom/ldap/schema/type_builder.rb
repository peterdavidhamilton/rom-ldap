require 'ber'
require 'rom/ldap/types'
require 'rom/initializer'

# Hash#slice
using ::Compatibility

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
      # @see Directory.attributes
      #
      # @see <https://docs.oracle.com/cd/E19450-01/820-6173/def-attribute-type.html>
      #
      # @param attributes [Array<Hash>]
      #
      # @api private
      class TypeBuilder
        extend Initializer

        param :attributes

        # @param attribute_name [String, Symbol]
        #
        # @param schema [Schema] Relation schema object.
        #
        # @api public
        def call(attribute_name, schema)
          attribute = attribute_by_name(attribute_name)
          primitive = map_type(attribute)
          multiple  = !attribute[:single] && primitive != 'Array'
          ruby_type = Types.const_get(primitive)
          read_type = multiple ? Types.const_get(Inflector.pluralize(primitive)) : ruby_type

          ruby_type.meta(
            name:     attribute_name,
            source:   schema,
            multiple: multiple,
            read:     read_type,
            **attribute.slice(:description, :original, :matcher, :oid)
          )
        end

        private

        # OPTIMIZE: also used in Attribute
        # Attribute whose formatted name matches the attribute name.
        #
        # @param name [Symbol, String]
        #
        # @return [Hash]
        #
        # @api private
        def attribute_by_name(attribute_name)
          attributes.detect { |a| a[:name] == attribute_name } || EMPTY_HASH
        end

        # Map attribute to Type using known OID or by inferring from the matchers.
        #
        # @param attribute [Hash]
        #
        # @return [String]
        #
        # @api private
        def map_type(attribute)
          by_oid(attribute[:oid]) || by_matcher(attribute[:matcher])
        end

        # @param oid [String]
        #
        # @return [String]
        #
        # @api private
        def by_oid(oid)
          ::BER.lookup(:oid, oid)
        end

        # @param matcher [String]
        #
        # @return [String]
        #
        # @api private
        def by_matcher(matcher)
          case matcher
          when *STRING_MATCHERS  then 'String'
          when *BOOLEAN_MATCHERS then 'Bool'
          when *INTEGER_MATCHERS then 'Int'
          when *TIME_MATCHERS    then 'Time'
          else
            'String'
          end
        end
      end
    end
  end
end
