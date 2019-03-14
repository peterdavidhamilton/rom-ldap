require 'rom/ldap/parsers/filter_expresser'
require 'rom/ldap/parsers/ast_expresser'
require 'rom/ldap/parsers/attribute'

module ROM
  module LDAP
    class Directory
      # Parsing Formats
      #
      # @api public
      module Tokenization

        # Allows adapters that subclass Directory to use custom parsers.
        # Extends the class with filter abstraction behavior.
        #
        # @api private
        def self.included(klass)
          klass.class_eval do
            extend Dry::Core::ClassAttributes

            defines :attribute_class
            defines :abstract_class
            defines :filter_class

            attribute_class Parsers::Attribute
            abstract_class  Parsers::ASTExpresser
            filter_class    Parsers::FilterExpresser
          end
        end


        private

        # Convert abstract criteria or LDAP filter into an expression object.
        #   Check for parsed attributes to prevent recursion.
        #
        # @param input [Array, String] RFC2254 or AST
        #
        def to_expression(input)
          if input.is_a?(String)
            klass = self.class.filter_class
            attrs = !!@attribute_types ? attribute_types : EMPTY_ARRAY
          else
            klass = self.class.abstract_class
            attrs = attribute_types
          end

          klass.new(input, schemas: attrs).call
        end


        # Create parsed attribute from definiton.
        #
        # @param attr_def [String]
        #
        # @return [Hash]
        #
        def to_attribute(attr_def)
          self.class.attribute_class.new(attr_def).call
        end

      end
    end
  end
end
