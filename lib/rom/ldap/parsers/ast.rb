require 'rom/ldap/parsers/base'
require 'rom/ldap/functions'

module ROM
  module LDAP
    module Parsers
      class AST < Base

        param :ast, type: Types::Strict::Array

        def call
          case ast.size
          when 2 then parse_join
          when 3 then parse_expression
          end
        end

        private

        # @return [Array]
        #
        def parse_expression
          ast
        end

        # @return [Array]
        #
        # @example => [ :constructor, [ (nested) ] ]
        #
        def parse_join
          left, right = ast
          expr = left.eql?(:con_not) ? with(right) : right.map(&method(:with))

          [left, expr]
        end

        def with(r)
          self.class.new(r, options).call
        end


        def decode_attribute(name)
          # directory
          #   .attribute_by(:name, scanner.matched)
          #   .fetch(:canonical, name)

          attr = schemas.find { |a| a[:name].eql?(name) }
          attr ? attr[:canonical] : name
        end

        # Check VALUES_MAP for encoded values otherwise return input.
        #
        # @param sym [Symbol,String] possible special value
        #
        # @return [String] "*", "TRUE", "FALSE"
        #
        def decode_value(sym)
          values.fetch(sym, sym)
        end

        # @param sym [Symbol] encoded version
        #
        # @return [Symbol,String]
        #
        def decode_constructor(sym)
          constructors.fetch(sym, :unknown_constructor)
        end

        # @param sym [Symbol] encoded version
        #
        # @return [Symbol,String]
        #
        def decode_operator(sym)
          operators.fetch(sym, :'???')
        end

      end
    end
  end
end
