require 'rom/ldap/filter/composer'
require 'rom/ldap/filter/decomposer'

module ROM
  module LDAP
    module Filter
      # join the compose from input -> decompose to output classes.
      #
      # @api public
      class Compiler

        extend Initializer

        param :input # string or array

        option :composer,   default: proc { Composer.new }
        option :decomposer, default: proc { Decomposer.new }

        # query in ast out
        def to_ast
          input.is_a?(String) ? composer.call(input) : input
        end

        # ast in query out
        def to_filter
          input.is_a?(Array) ? decomposer.call(input) : input
        end

      end
    end
  end
end
