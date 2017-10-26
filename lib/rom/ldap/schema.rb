require 'rom/schema'
require 'rom/ldap/schema/dsl'
require 'rom/ldap/schema/inferrer'

module ROM
  module LDAP
    class Schema < ROM::Schema

      # used by Relation#view
      def call(relation)
        relation.new(relation.dataset, schema: self)
      end

      # Return an empty schema
      #
      # @return [Schema]
      #
      # @api public
      def empty
        new(EMPTY_ARRAY)
      end

      # @api private
      def finalize_attributes!(options = EMPTY_HASH)
        super do
          initialize_primary_key_names
        end
      end

      # @api private
      def finalize_associations!(relations:)
        super do
          associations.map do |definition|
            LDAP::Associations.const_get(definition.type).new(definition, relations)
          end
        end
      end

    end
  end
end
