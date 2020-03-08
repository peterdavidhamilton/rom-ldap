require 'rom/ldap/expression'

module ROM
  module LDAP
    module Parsers
      #
      # Parses and AST into and Expression/RFC filter
      #
      # @api private
      class AbstractSyntax

        extend Initializer

        param :ast, type: Types::Strict::Array

        param :attributes, type: Types.Array(Types::Hash)

        def call
          case ast.size

          # Join or negate expression
          when 2
            constructor, part = ast

            expressions =
              if constructor.eql?(:con_not)
                [express(part)]
              else
                part.map(&method(:express))
              end

            Expression.new(op: constructor, exps: expressions)

          # Create expression
          when 3
            operator, attribute, value = ast

            Expression.new(
              op: operator,
              field: decode_attribute(attribute),
              value: decode_value(value)
            )
          end
        end

        private

        # Express a nested AST
        #
        # @api private
        def express(ast_part)
          self.class.new(ast_part, attributes).call
        end

        def decode_attribute(name)
          attr = attributes.find { |a| a[:name].eql?(name) }
          attr ? attr[:canonical] : name
        end

        # Check VALUES_MAP for encoded values otherwise return input.
        #
        # @param sym [Symbol,String] possible special value
        #
        # @return [String] "*", "TRUE", "FALSE"
        #
        def decode_value(sym)
          VALUES_MAP.fetch(sym, sym)
        end

        # @param sym [Symbol] encoded version
        #
        # @return [Symbol,String]
        #
        def decode_constructor(sym)
          CONSTRUCTORS.fetch(sym, :unknown_constructor)
        end

        # @param sym [Symbol] encoded version
        #
        # @return [Symbol,String]
        #
        def decode_operator(sym)
          OPERATORS.fetch(sym, :'???')
        end

      end
    end
  end
end
