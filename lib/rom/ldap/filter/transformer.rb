require 'rom/ldap/filter/transformer/composer'
require 'rom/ldap/filter/transformer/decomposer'
require 'rom/ldap/filter/transformer/parser'

module ROM
  module LDAP
    module Filter
      # Handle transforming between AST, LDAP and Expression.
      #
      # @api public
      class Transformer
        extend Initializer

        param :input

        option :parser,     default: -> { Parser.new }
        option :composer,   default: -> { Composer.new }
        option :decomposer, default: -> { Decomposer.new }

        # string -> ast
        def to_ast
          input.is_a?(String) ? composer.call(input) : input
        end

        # ast -> string
        def to_s
          input.is_a?(Array) ? decomposer.call(input) : input
        end

        # ast/string -> Expression
        def to_exp
          input.is_a?(String) ? parser.call(input) : parser.call(to_s)
        end

      end
    end
  end
end
