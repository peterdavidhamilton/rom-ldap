require 'rom/ldap/parsers/filter'
require 'rom/ldap/expression'

module ROM
  module LDAP
    module Parsers
      #
      #   Filter encode to Expression
      #
      class FilterExpresser < Filter

        #
        # [:constuctor_sym, 'originalAttrbute', 'value']
        #
        def call
          if start_statement
            if joined_statement
              join_type = encode_constructor

              while (branch = call)
                statements << branch
              end

              if compound_statement?
                self.result = next_statement.with(join_type, next_statement) until no_statements?
              end

            elsif negated_statement
              negator = encode_constructor
              self.result = call.with(negator)

            else
              skip_whitespace
              scan_attribute
              attribute = scanner.matched

              skip_whitespace
              scan_operator
              op = encode_operator

              skip_whitespace
              scan_value
              value = scanner.matched
              value.strip! unless value.nil?

              self.result = Expression.new(op, attribute, value)
            end

            close_statement

            self.result
          end
        end

        private


        # @return [Array<Expression>]
        #
        def statements
          @statements ||= []
        end

        # @return [Boolean]
        #
        def compound_statement?
          statements.size >= 1
        end

        def next_statement
          statements.shift
        end

        # @return [Boolean]
        #
        def no_statements?
          statements.empty?
        end

      end
    end
  end
end
