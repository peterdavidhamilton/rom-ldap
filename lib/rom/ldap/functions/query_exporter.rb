require 'strscan'
require 'rom/ldap/functions/lookup'

module ROM
  module LDAP
    module Functions
      # Translate a filter string to an abstracted query.
      #
      # @api private
      class QueryExporter
        include Lookup

        # @param string [String]
        #
        # @return [Array]
        #
        # @api public
        def call(string)
          @scanner = StringScanner.new(string.to_str)
          parse
        end

        alias [] call

        private

        attr_reader :scanner

        # @return [Array]
        #
        # @api private
        def parse
          if scanner.scan(OPEN_REGEX)
            if scanner.scan(BRANCH_REGEX)
              const    = id_constructor(scanner.matched)
              branches = []

              while (branch = parse)
                branches << branch
              end

              arr = [const, branches]

            elsif scanner.scan(NOT_REGEX)
              const = id_constructor(scanner.matched)
              arr   = [const, parse]

            else
              arr = parse_expression
            end

            arr if arr && scanner.scan(CLOSE_REGEX)
          end
        end

        # This is a lexer.
        #
        # Tokenise the operator, attribute, value parts of an expression.
        #
        # @example
        #   => [:op_eql, 'uidNumber', :wildcard]
        #
        # @return [Array]
        #
        # @api private
        def parse_expression
          scanner.scan(WS_REGEX)
          scanner.scan(ATTR_REGEX)
          attribute = scanner.matched
          # attribute = id_attribute(scanner.matched)

          scanner.scan(WS_REGEX)
          scanner.scan(OP_REGEX)
          operator = id_operator(scanner.matched)

          scanner.scan(WS_REGEX)
          scanner.scan(VAL_REGEX)
          # value = id_value(scanner.matched)
          value = Functions[:identify_value].call(scanner.matched)

          [operator, attribute, value]
        end
      end
    end
  end
end
