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


        # def call
        #   case input
        #   when String then composer.call(input)
        #   when Array  then decomposer.call(input)
        #   else
        #     input
        #   end
        # end

        # string -> ast
        def to_a
          input.is_a?(String) ? composer.call(input) : input
        end

        # alias to_a call
        alias to_ast to_a

        # ast -> string
        def to_s
          input.is_a?(Array) ? decomposer.call(input) : input
        end

        # alias to_s call
        alias to_filter to_s

        # ast/string -> Expression
        def to_exp
          if input.is_a?(String)
            parser.call(input)
          else
            parser.call(to_s)
          end
        end



      end
    end
  end
end
