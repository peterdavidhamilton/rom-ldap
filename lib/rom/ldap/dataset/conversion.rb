# frozen_string_literal: true

require 'rom/ldap/parsers/abstract_syntax'
require 'rom/ldap/parsers/filter_syntax'

module ROM
  module LDAP
    class Dataset

      # Parsing Formats
      #
      # @api public
      module Conversion
        # Extends the class with filter abstraction behavior.
        #
        # @api private
        def self.included(klass)
          klass.class_eval do
            extend Dry::Core::ClassAttributes

            defines :filter_class
            filter_class Parsers::FilterSyntax

            defines :ast_class
            ast_class Parsers::AbstractSyntax
          end
        end

        # Convert the full query to an LDAP filter string
        #
        # @return [String]
        #
        # @api private
        def to_filter
          self.class.ast_class.new(to_ast, directory.attribute_types).call.to_filter
        end

        # Combine original relation dataset name (LDAP filter string)
        #   with search criteria (AST).
        #
        # @return [Array]
        #
        # @api private
        def to_ast
          criteria.empty? ? source_ast : [:con_and, [source_ast, criteria]]
        end

        private

        # Convert the relation's source filter string to a query AST.
        #
        # @return [Array]
        #
        # @api private
        def source_ast
          self.class.filter_class.new(name, directory.attribute_types).call
        end
      end

    end
  end
end
