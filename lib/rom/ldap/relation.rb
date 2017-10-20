require 'rom/ldap/types'
require 'rom/ldap/schema'
require 'rom/ldap/schema/inferrer'
require 'rom/ldap/attribute'
require 'rom/ldap/relation/reading'
require 'rom/ldap/relation/writing'

module ROM
  module LDAP
    class Relation < ROM::Relation
      adapter :ldap

      include Reading
      include Writing

      schema_class      Schema
      schema_attr_class Attribute
      schema_inferrer   Schema::Inferrer.new.freeze

      # wrap_class      SQL::Wrap # TODO: research relevance

      forward(*Dataset::DSL.query_methods)

      def primary_key
        attribute = schema.find(&:primary_key?)

        if attribute
          attribute.alias || attribute.name
        else
          :id
        end
      end


      # available methods provided by DSL
      #
      # @return [Array]
      # @api private
      #
      def query_methods
        Dataset::DSL.query_methods.sort
      end
      private :query_methods

      def project(*names)
        with(schema: schema.project(*names.flatten))
      end

      def exclude(*names)
        with(schema: schema.exclude(*names.flatten))
      end

      def rename(mapping)
        with(schema: schema.rename(mapping))
      end

      def prefix(prefix)
        with(schema: schema.prefix(prefix))
      end

      def wrap(prefix=dataset.name)
        with(schema: schema.wrap(prefix))
      end

    end
  end
end
