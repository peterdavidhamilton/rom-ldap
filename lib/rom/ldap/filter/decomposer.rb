require 'rom/ldap/filter'
require 'rom/ldap/filter/expression'

module ROM
  module LDAP
    module Filter
      # Transform an AST into a filter expression
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
          when 1 then single(ast.first) # extra array wrapping
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
          # operator = id_operator(op)
          value    = id_value(val)
          # "(#{attribute}#{operator}#{value})"

          Expression.new(op, attribute, value)
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
            expressions = single(right)
            "(#{constructor}#{expressions})"

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


        # @param sym [Symbol]
        #
        # @example
        #   id_constructor(:con_and) => '&'
        #
        # @return [String]
        #
        # @api private
        def id_constructor(sym)
          CONSTRUCTORS[sym]
        end

        # @param sym [Symbol]
        #
        # @example
        #   id_operator(:op_gt_eq) => '>='
        #
        # @return [String]
        #
        # @api private
        def id_operator(sym)
          OPERATORS[sym]
        end

        # @param sym [Symbol]
        #
        # @example
        #   id_value(:val_true) => 'TRUE'
        #   id_value('peter hamilton') => 'peter hamilton'
        #
        # @return [String]
        #
        # @api private
        def id_value(sym)
          VALUES.fetch(sym, sym)
        end

      end
    end
  end
end
