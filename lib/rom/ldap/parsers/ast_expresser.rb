require 'rom/ldap/parsers/ast'
require 'rom/ldap/expression'

module ROM
  module LDAP
    module Parsers
      #
      #   AST encode to Expression
      #
      class ASTExpresser < AST

        private

        # Only decode attribute and value.
        #   Expression uses original attrs and encoded operators.
        #
        # @return [Expression]
        #
        # @api private
        def parse_expression
          operator, attribute, value = super

          attribute = decode_attribute(attribute)
          value     = decode_value(value)

          Expression.new(operator, attribute, value)
        end

        # Combine expressions with constructor into a nested expression.
        #
        # @return [Expression]
        #
        # @api private
        def parse_join
          constructor, expressions = super

          Expression.new(constructor, *expressions)
        end

      end
    end
  end
end
