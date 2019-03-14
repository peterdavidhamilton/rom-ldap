module ROM
  module LDAP
    module Parsers


      VAL_REGEX         = /(?:[-\[\]{}\w*.+\/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]|[^\x00-\x7F]|\\[a-fA-F\d]{2})+/u
      OPERATOR_REGEX    = Regexp.union(*OPERATORS.values)
      CONSTRUCTOR_REGEX = Regexp.union(/\s*\|\s*/, /\s*\&\s*/)

      #
      #  Rfc2254 -> AST          # Rfc2254Abstracter
      #  Rfc2254 -> Expression   # Rfc2254Expresser
      #
      #  AST     -> Rfc2254      # ASTRecompiler
      #  AST     -> Expression   # ASTExpresser
      #
      class Base

        extend Initializer

        option :schemas, reader: :private

        option :constructors,
          type: Dry::Types['strict.hash'],
          default: -> { CONSTRUCTORS }

        option :operators,
          type: Dry::Types['strict.hash'],
          default: -> { OPERATORS }

        option :values,
          type: Dry::Types['strict.hash'],
          default: -> { VALUES_MAP }


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
