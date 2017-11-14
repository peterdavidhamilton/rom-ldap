require 'strscan'
require 'rom/ldap/filter'

module ROM
  module LDAP
    module Filter
      # Build abstract syntax tree from ldap filter string
      #
      # @api private
      class Composer
        include Filter

        def call(string)
          @scanner = StringScanner.new(string)
          parse_expression
        end

        alias [] call

        private

        attr_reader :scanner

        # @return [Array]
        #
        # @api private
        def parse_expression
          if scanner.scan(OPEN_REGEX)
            if scanner.scan(BRANCH_REGEX)
               const    = id_constructor(scanner.matched)
               branches = []

               while branch = parse_expression
                 branches << branch
               end

               expr = [const, branches]

             elsif scanner.scan(NOT_REGEX)
               const = id_constructor(scanner.matched)
               expr  = [const, parse_expression]

             else
               expr = parse_branch
             end

            expr if expr && scanner.scan(CLOSE_REGEX)
          end
        end

        # This is a lexer.
        #
        # Tokenise the operator, attribute, value parts of an expression.
        #
        # @example
        #   => [:op_equal, 'uidNumber', :wildcard]
        #
        # @return [Array]
        #
        # @api private
        def parse_branch
          scanner.scan(WS_REGEX)
          scanner.scan(ATTR_REGEX)
          attribute = scanner.matched

          scanner.scan(WS_REGEX)
          scanner.scan(OP_REGEX)
          operator = id_operator(scanner.matched)

          scanner.scan(WS_REGEX)
          scanner.scan(VAL_REGEX)
          value = id_value(scanner.matched)

          [operator, attribute, value]
        end


        # @param str [String]
        #
        # @example
        #   id_constructor('&') => :con_and
        #
        # @return [Symbol]
        #
        # @api private
        def id_constructor(str)
          CONSTRUCTORS.invert[str]
        end

        # @param str [String]
        #
        # @example
        #   id_operator('>=') => :op_gt_eq
        #
        # @return [Symbol]
        #
        # @api private
        def id_operator(str)
          OPERATORS.invert[str]
        end

        # @param str [String]
        #
        # @example
        #   id_value('TRUE') => true
        #   id_value('peter hamilton') => 'peter hamilton'
        #
        # @return [Symbol,String,Boolean]
        #
        # @api private
        def id_value(str)
          VALUES.invert.fetch(str, str)
        end

      end
    end
  end
end
