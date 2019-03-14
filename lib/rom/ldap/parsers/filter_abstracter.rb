require 'rom/ldap/parsers/filter'

module ROM
  module LDAP
    module Parsers
      #
      # @abstract
      # Filter lexer to AST
      #
      class FilterAbstracter < Filter

        def call
          if start_statement
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

            self.result
          end
        end


      end
    end
  end
end
