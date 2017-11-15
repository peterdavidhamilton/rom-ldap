require 'rom/ldap/filter'

module ROM
  module LDAP
    module Filter
      class Transformer
        # Build an LDAP filter string from an abstract syntax tree (AST).
        #
        # @api private
        class Decomposer
          include Filter

          # Called by Directory#query to generate the expression which is passed to Connection#search
          #
          # @return [Filter::Expression]
          #
          def call(ast)
            case ast.size
            when 0 then EMPTY_STRING
            when 1 then call( ((ast.first).is_a?(Symbol) ? ast : ast.first)  ) # extra array wrapping
            # when 1 then call( ( constructed(ast) ? ast : ast.first )  ) # extra array wrapping
            when 2 then constructed(ast)  # &, |, !
            when 3 then single(ast)       # simple expression
            else
              :wip
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
            "(#{attribute}#{operator}#{value})"
          end

          # @param ast [Array]
          #
          # @return [String]
          #
          # @example
          #   => [:con_not, [:op_equal, 'uidNumber', :wildcard]]
          #   => [:con_and, [
          #         [:op_equal, 'uidNumber', :wildcard],
          #         [:op_equal, 'registered', true]
          #       ]]
          #
          # @api private
          def constructed(ast)
            left, right = ast
            constructor = id_constructor(left)

            if left == :con_not
              expression = single(right)
              "(#{constructor}#{expression})"

            elsif constructed?(right)
              expressions = right.map(&method(:call)).join
              "(#{constructor}#{expressions})"

            else
              expressions = right.map(&method(:single)).join
              "(#{constructor}(#{expressions}))"
            end
          end


          # Identify nested expressions that start with constructors
          #
          # @param expr [Array]
          #
          # @return [Boolean]
          #
          # @api private
          def constructed?(expr)
            expr.any? { |x| CONSTRUCTORS.keys.include?(x.first) }
          end

        end
      end
    end
  end
end
