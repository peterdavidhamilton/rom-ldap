require 'strscan'
require_relative 'lookup'
require 'rom/ldap/expression'

module ROM
  module LDAP
    module Functions
      # Build a nested Expression object from an LDAP filter string.
      #
      # @api private
      class ExpressionExporter
        include Lookup

        def call(string)
          Types::Strict::String[string]

          @scanner = StringScanner.new(string)
          parse_expression
        end

        alias [] call

        private

        attr_reader :scanner

        def parse_expression
          if scanner.scan(OPEN_REGEX)
            if scanner.scan(BRANCH_REGEX)
              const = scanner.matched
              branches = []

              while branch = parse_expression
                branches << branch
              end

              if branches.size >= 1
                expr = branches.shift
                expr = expr.__send__(const, branches.shift) until branches.empty?
              end

             elsif scanner.scan(NOT_REGEX)
               expr = ~parse_expression

             else
               expr = parse_branch
             end

            expr if expr && scanner.scan(CLOSE_REGEX)
          end
        end

        # This is a lexer.
        #
        # Create an Expression object that can call #to_ber
        #
        # @example
        #   => <#ROM::LDAP::Filter::Expression op=and left=() right=(mail~=*@example.com)>
        #
        # @return [Expression]
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
          value = scanner.matched

          Expression.new(operator, attribute, value)
        end

      end
    end
  end
end
