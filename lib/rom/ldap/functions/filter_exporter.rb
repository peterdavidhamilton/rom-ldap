require_relative 'lookup'

module ROM
  module LDAP
    module Functions
      # Translate an abstracted query to a filter string.
      #
      # @api private
      class FilterExporter
        include Lookup

        # Called by Directory#query to generate the expression which is passed to Connection#search
        #
        # @return [Expression]
        #
        def call(ast)
          case ast.size
          when 2 then parse(ast)
          when 3 then parse_expression(ast)
          end
        end

        alias [] call

        private

        # @param ast [Array]
        #
        # @return [String]
        #
        # @example
        #   => [:op_eq, 'uidNumber', :wildcard]
        #
        # @api private
        def parse_expression(ast)
          op, attribute, val = ast
          operator = id_operator(op)
          value    = id_value(val)

          wrap(attribute, operator, value)
        end

        # @param ast [Array]
        #
        # @return [String]
        #
        # @example
        #   => [:con_not, [:op_eq, 'uidNumber', :wildcard]]
        #   => [
        #         :con_and,
        #         [
        #           [:op_eq, 'uidNumber', :wildcard],
        #           [:op_eq, 'registered', true]
        #         ]
        #      ]
        #
        # @api private
        def parse(ast)
          left, right = ast
          expr = left.eql?(:con_not) ? call(right) : right.map(&method(:call)).join
          constructor = id_constructor(left)
          wrap(constructor, expr)
        end

        # Stringify params and wrap with parentheses.
        #
        # @api private
        def wrap(*attrs)
          "(#{attrs.join})"
        end
      end
    end
  end
end
