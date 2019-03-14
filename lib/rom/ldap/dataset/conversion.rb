require 'rom/ldap/parsers/ast_recompiler'
require 'rom/ldap/parsers/filter_abstracter'

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

            defines :ast_class
            defines :filter_class

            ast_class    Parsers::FilterAbstracter
            filter_class Parsers::ASTRecompiler
          end

          # @return [Parsers::Rfc2254Abstracter]
          #
          # @api public
          def filter_to_ast
            self.class.ast_class
          end

          # @return [Parsers::ASTRecompiler]
          #
          # @api public
          def ast_to_filter
            self.class.filter_class
          end
        end

        # Convert the full query to an LDAP filter string
        #
        # @return [String]
        #
        # @api private
        def to_filter
          ast_to_filter.new(to_ast, schemas: directory.attribute_types).call
        end

        # Combine original relation dataset name (LDAP filter string)
        #   with search criteria (AST).
        #
        # @return [String]
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
          filter_to_ast.new(name, schemas: directory.attribute_types).call
        end

      end
    end
  end
end
