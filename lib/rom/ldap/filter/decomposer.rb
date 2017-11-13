require 'rom/ldap/filter'

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

          # extra array wrapping
          when 1 then single(ast.first)

          # &, |, !
          when 2
            left, right = ast
            constructor = id_constructor(left)
            expressions = right.map { |exp| single(exp) }.join
            "(#{constructor}(#{expressions}))"

          # simple expression
          when 3 then single(ast)

          else
            :wip
          end
        end

        alias [] call

        private

        def single(ast)
          op, attribute, val = ast
          operator = id_operator(op)
          value    = id_value(val)
          "(#{attribute}#{operator}#{value})"
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
