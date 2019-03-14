require 'rom/ldap/parsers/base'
require 'strscan'

module ROM
  module LDAP
    module Parsers
      #
      # @abstract
      # Lexer for transforming string representation of search filters.
      #
      class Filter < Base

        param :string, type: Types::Filter

        attr_accessor :result

        private

        # @return [StringScanner]
        #
        def scanner
          @scanner ||= StringScanner.new(string)
        end

        def skip_whitespace
          scanner.scan(/\s*/)
        end

        def close_statement
          scanner.scan(/\s*\)\s*/)
        end

        def start_statement
          scanner.scan(/\s*\(\s*/)
        end

        # @return [String,nil] "!"
        #
        def negated_statement
          scanner.scan(/\s*\!\s*/)
        end

        # @return [String,nil] "&" or "|"
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
          attr = schemas.find { |a| a[:canonical].eql?(scanner.matched) }
          attr ? attr[:name] : scanner.matched
        end


        # @return [Symbol]
        #
        def encode_value
          value = scanner.matched
          value.strip! unless value.nil?
          values.invert.fetch(value, value)
        end

        # @return [Symbol]
        #
        def encode_constructor
          constructors.invert[scanner.matched]
        end

        # @return [Symbol]
        #
        def encode_operator
          operators.invert[scanner.matched]
        end


      end
    end
  end
end
