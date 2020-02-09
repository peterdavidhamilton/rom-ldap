require 'strscan'

module ROM
  module LDAP
    module Parsers
      #
      # Parses a filter into an AST
      #
      # @api private
      class FilterSyntax

        extend Initializer

        param :filter, type: Types::Filter

        param :attributes, type: Types::Array.of(Types::Hash)

        attr_accessor :result

        def call
          if open_statement
            if joined_statement
              join_type = encode_constructor

              branches = []

              while (branch = call)
                branches << branch
              end

              self.result = [join_type, branches]

            elsif negated_statement
              negator = encode_constructor
              self.result = [negator, call]

            else
              skip_whitespace
              scan_attribute
              attribute = encode_attribute

              skip_whitespace
              scan_operator
              op = encode_operator

              skip_whitespace
              scan_value
              value = encode_value

              self.result = [op, attribute, value]
            end

            close_statement

            result
          end
        end

        private

        # @return [StringScanner]
        #
        def scanner
          @scanner ||= StringScanner.new(filter)
        end

        def skip_whitespace
          scanner.scan(/\s*/)
        end

        def close_statement
          scanner.scan(/\s*\)\s*/)
        end

        def open_statement
          scanner.scan(/\s*\(\s*/)
        end

        # @return [String, NilClass] "!"
        #
        def negated_statement
          scanner.scan(/\s*\!\s*/)
        end

        # @return [String, NilClass] "&" or "|"
        #
        def joined_statement
          scanner.scan(CONSTRUCTOR_REGEX)
        end

        def scan_value
          scanner.scan(VAL_REGEX)
        end

        def scan_operator
          scanner.scan(OPERATOR_REGEX)
        end

        def scan_attribute
          scanner.scan(/[-\w:.]*[\w]/)
        end

        # @return [String,Symbol] formatted
        #
        def encode_attribute
          attr = attributes.find { |a| a[:canonical].eql?(scanner.matched) }
          attr ? attr[:name] : scanner.matched
        end

        # @return [Mixed]
        #
        def encode_value
          Functions[:identify_value].call(scanner.matched)
        end

        # @return [Symbol]
        #
        def encode_constructor
          CONSTRUCTORS.invert[scanner.matched]
        end

        # @return [Symbol]
        #
        def encode_operator
          OPERATORS.invert[scanner.matched]
        end

      end
    end
  end
end
