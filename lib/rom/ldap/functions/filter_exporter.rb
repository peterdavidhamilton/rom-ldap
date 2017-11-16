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
        # @return [Filter::Expression]
        #
        def call(ast)
          Types::Array[ast]

          case ast.size
          when 0 then EMPTY_STRING
          when 1 then call( ((ast.first).is_a?(Symbol) ? ast : ast.first)  ) # extra array wrapping
          when 2 then constructed(ast)  # &, |, !
          when 3 then single(ast)       # simple expression
          else
            :filter_export_error
          end
        end

        alias [] call

        private

        # @param ast [Array]
        #
        # @return [String]
        #
        # @example
        #   => [:op_equal, 'uidNumber', :wildcard]
        #
        # @api private
        def single(ast)
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
        #   => [:con_not, [:op_equal, 'uidNumber', :wildcard]]
        #   => [
        #         :con_and,
        #         [
        #           [:op_equal, 'uidNumber', :wildcard],
        #           [:op_equal, 'registered', true]
        #         ]
        #      ]
        #
        # @api private
        def constructed(ast)
          left, right = ast
          expr = left.eql?(:con_not) ? single(right) : right.map(&method(:call)).join
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
