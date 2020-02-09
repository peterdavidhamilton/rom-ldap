require 'rom/ldap/parsers/abstract_syntax'
require 'rom/ldap/parsers/filter_syntax'
require 'rom/ldap/parsers/attribute'

module ROM
  module LDAP
    class Directory

      # Parsing Formats
      #
      # @api private
      module Tokenization
        # Allows adapters that subclass Directory to use custom parsers.
        # Extends the class with filter abstraction behavior.
        #
        # @api private
        def self.included(klass)
          klass.class_eval do
            extend Dry::Core::ClassAttributes

            defines :attribute_class
            attribute_class Parsers::Attribute

            defines :filter_class
            filter_class Parsers::FilterSyntax

            defines :ast_class
            ast_class Parsers::AbstractSyntax
          end
        end

        private

        # Convert abstract criteria or LDAP filter into an expression object.
        #   Check for parsed attributes to prevent recursion.
        #
        # @param input [Array, String] RFC2254 or AST
        #
        def to_expression(input)
          attrs = !@attribute_types.nil? ? attribute_types : EMPTY_ARRAY

          # Filter > AST
          unless input.is_a?(Array)
            input = self.class.filter_class.new(input, attrs).call
          end

          # AST > Expression
          self.class.ast_class.new(input, attrs).call
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
