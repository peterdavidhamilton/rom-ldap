require 'strscan'
require 'rom/ldap/filter'

module ROM
  module LDAP
    module Filter
      class Transformer
        # Build an abstract syntax tree (AST) from an LDAP filter string.
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

                 arr = [const, branches]

               elsif scanner.scan(NOT_REGEX)
                 const = id_constructor(scanner.matched)
                 arr  = [const, parse_expression]

               else
                 arr = parse_branch
               end

              arr if arr && scanner.scan(CLOSE_REGEX)
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

        end
      end
    end
  end
end
