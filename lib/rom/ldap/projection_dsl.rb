require 'rom/ldap/dsl'

module ROM
  module LDAP
    # Projection DSL used in reading API (`select`, `select_append` etc.)
    #
    # @see LDAP::Schema#project
    #
    # @api public
    class ProjectionDSL < DSL

      # @api private
      def respond_to_missing?(name, include_private = false)
        super || type(name)
      end

      private

      # @api private
      def method_missing(meth, *args, &block)
        if schema.key?(meth)
          schema[meth]
        else
          type = type(meth)

          if type
            ::ROM::LDAP::Attribute[type].value(args[0])
          else
            super
          end
        end
      end
    end
  end
end
