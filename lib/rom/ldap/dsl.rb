require 'concurrent/map'
require 'rom/support/inflector'
require 'rom/constants'

require 'rom/ldap/types'
require 'rom/ldap/parsers/filter_abstracter'

module ROM
  module LDAP
    # @api private
    class DSL < BasicObject
      # @!attribute [r] schema
      #   @return [LDAP::Schema]
      attr_reader :schema

      # @!attribute [r] relations
      #   @return [Hash, RelationRegistry]
      attr_reader :relations

      # @!attribute [r] picked_relations
      #   @return [Concurrent::Map]
      attr_reader :picked_relations

      # @api private
      def initialize(schema)
        @schema = schema
        @relations = schema.respond_to?(:relations) ? schema.relations : EMPTY_HASH
        @picked_relations = ::Concurrent::Map.new
      end

      # @api private
      def call(&block)
        result = instance_exec(select_relations(block.parameters), &block)

        if result.is_a?(::Array)
          result
        else
          [result]
        end
      end

      # Parse a raw query to AST.
      #
      # @param [String] value
      #
      # @return [AST]
      #
      # @api public
      def `(value)
        Parsers::FilterAbstracter.new(value, schemas: EMPTY_ARRAY).call
      end

      # @api private
      def respond_to_missing?(name, include_private = false)
        super || schema.key?(name)
      end

      private

      # @api private
      def type(identifier)
        type_name = Inflector.classify(identifier)
        types.const_get(type_name) if types.const_defined?(type_name)
      end

      # @api private
      def types
        ::ROM::LDAP::Types
      end

      # @api private
      def select_relations(parameters)
        @picked_relations.fetch_or_store(parameters.hash) do
          keys = parameters.select { |type, _| type == :keyreq }

          if keys.empty?
            relations
          else
            keys.each_with_object({}) { |(_, k), rs| rs[k] = relations[k] }
          end
        end
      end
    end
  end
end
