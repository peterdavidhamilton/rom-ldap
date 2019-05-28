module ROM
  module LDAP
    module Parsers


      VAL_REGEX         = /(?:[-\[\]{}\w*.+\/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]|[^\x00-\x7F]|\\[a-fA-F\d]{2})+/u
      OPERATOR_REGEX    = Regexp.union(*OPERATORS.values)
      CONSTRUCTOR_REGEX = Regexp.union(/\s*\|\s*/, /\s*\&\s*/)

      #
      #  Filter -> AST         # FilterAbstracter
      #  Filter -> Expression  # FilterExpresser
      #
      #  AST    -> Filter      # ASTRecompiler
      #  AST    -> Expression  # ASTExpresser
      #
      class Base

        extend Initializer

        option :schemas, reader: :private

        option :constructors, type: Types::Strict::Hash, default: -> { CONSTRUCTORS }

        option :operators, type: Types::Strict::Hash, default: -> { OPERATORS }

        option :values, type: Types::Strict::Hash, default: -> { VALUES_MAP }


        # @raise [NotImplementedError]
        #
        # @api public
        def call
          raise NotImplementedError
        end

        alias [] call

      end
    end
  end
end
