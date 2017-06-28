require 'rom/schema'
require 'rom/ldap/types'

module ROM
  module Ldap
    class Schema < ROM::Schema

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
            Ldap::Associations.const_get(definition.type).new(definition, relations)
          end
        end
      end

      def call(relation)
        relation.new(relation.dataset.select(*self), schema: self)
      end
    end
  end
end
