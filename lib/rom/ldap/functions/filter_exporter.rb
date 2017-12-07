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
        # @param ast [Array]
        #
        # @return [Expression]
        #
        # @api public
        def call(ast)
          case ast.to_ary.size
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
        #   => [:op_eql, 'uidNumber', :wildcard]
        #
        # @api private
        def parse_expression(ast)
          op, attr, val = ast
          operator  = id_operator(op)
          # value     = id_value(val)
          value = Functions[:identify_value].call(val)
          attribute = id_attribute(attr)

          wrap(attribute, operator, value)
        end

        # @param ast [Array]
        #
        # @return [String]
        #
        # @example
        #   => [:con_not, [:op_eql, 'uidNumber', :wildcard]]
        #   => [
        #         :con_and,
        #         [
        #           [:op_eql, 'uidNumber', :wildcard],
        #           [:op_eql, 'registered', true]
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
