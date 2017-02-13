# Not Schema DSL

module ROM
  module Ldap
    class DSL < BasicObject
      # @api private
      attr_reader :schema

      # @api private
      def initialize(schema)
        @schema = schema
      end

      # @api private
      def respond_to_missing?(name, include_private = false)
        super || schema.key?(name)
      end
    end
  end
end
