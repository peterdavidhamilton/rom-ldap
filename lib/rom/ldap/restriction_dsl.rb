require 'rom/ldap/dsl'
require 'rom/ldap/parsers/filter_syntax'

module ROM
  module LDAP
    # @api private
    class RestrictionDSL < DSL

      # @api private
      def call(&block)
        instance_exec(select_relations(block.parameters), &block)
      end

      # Parse a raw query to AST.
      #
      # @param [String] value
      #
      # @return [AST]
      #
      # @example
      #   animals.where { `(cn=dodo)` }.count
      #
      # @api public
      def `(value)
        Parsers::FilterSyntax.new(value, EMPTY_ARRAY).call
      end

      private

      # @return [Attribute, Type]
      #
      # @api private
      def method_missing(meth, *args, &block)
        if schema.key?(meth)
          schema[meth]
        else
          type(meth)
        end
      end

    end
  end
end
