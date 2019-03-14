require 'rom/ldap/parsers/ast'

module ROM
  module LDAP
    module Parsers
      #
      #   AST recompile to Filter string
      #
      class ASTRecompiler < AST

        private

        # Decode all three.
        #
        def parse_expression
          operator, attribute, value = super

          attribute = decode_attribute(attribute)
          value     = decode_value(value)
          operator  = decode_operator(operator)

          wrap(attribute, operator, value)
        end


        #
        def parse_join
          constructor, filters = super

          constructor = decode_constructor(constructor)

          wrap(constructor, *filters)
        end

        def wrap(*attrs)
          "(#{attrs.join})"
        end

      end
    end
  end
end
