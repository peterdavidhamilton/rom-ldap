require 'rom/ldap/filter'

module ROM
  module LDAP
    module Filter
      class Decomposer
        include Filter

        def call(ast)
          # raise if ast is not an array

          case ast.size

          # a branch
          when 2
            left, right = ast
            # raise if cnst is nil

            if left.is_a?(Symbol)
              case left
              when :con_and, :con_or
                binding.pry
                constructor = id_constructor(left)
                expression  = call(right)

                "(#{constructor}(#{expression}))"
              when :con_not

                constructor = id_constructor(left)
                expression  = call(right)
              end
            else
              binding.pry
            end

          # an expression
          when 3
            op, attribute, val = ast
            operator = id_operator(op)
            # raise if operator is nil
            value    = id_value(val)

            "(#{attribute}#{operator}#{value})"

          else

          end


        end

        alias [] call

        private


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
