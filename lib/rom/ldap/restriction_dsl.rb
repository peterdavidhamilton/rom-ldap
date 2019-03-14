require 'rom/ldap/dsl'

module ROM
  module LDAP
    # @api private
    class RestrictionDSL < DSL
      # @api private
      def call(&block)
        instance_exec(select_relations(block.parameters), &block)
      end

      private

      # @api private
      def method_missing(meth, *args, &block)
        if schema.key?(meth)
          schema[meth]
        else
          type(meth)
        end
      end
    end
  end
end
