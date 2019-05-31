require 'rom/schema'
require 'rom/ldap/schema/dsl'
require 'rom/ldap/restriction_dsl'
require 'rom/ldap/schema/inferrer'

module ROM
  module LDAP
    class Schema < ROM::Schema

      # Open restriction DSL for defining query conditions using schema attributes
      #
      # @see Relation#where
      #
      # @return [Mixed] Result of the block call
      #
      # @api public
      def restriction(&block)
        RestrictionDSL.new(self).call(&block)
      end


      # Create a new relation based on the schema definition
      #
      # @param relation [Relation] The source relation
      #
      # @return [Relation]
      #
      # @api public
      def call(relation)
        relation.new(relation.dataset, schema: self)
      end

      # Project schema so that it only contains primary key
      #
      # @return [Schema]
      #
      # @api private
      def project_pk
        project(*primary_key_names)
      end

      # Return a new schema with attributes marked as qualified
      #
      # @param table_alias [?]
      #
      # @return [Schema]
      #
      # @api public
      def qualified(table_alias = nil)
        new(map { |attr| attr.qualified(table_alias) })
      end

      # Join with another schema
      #
      # @param [Schema] other The other schema to join with
      #
      # @return [Schema]
      #
      # @api public
      def join(other)
        merge(other.joined)
      end

      # Return a new schema with all attributes marked as joined
      #
      # @return [Schema]
      #
      # @api public
      def joined
        new(map(&:joined))
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
      def finalize_attributes!(options = EMPTY_OPTS)
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

      memoize :qualified, :project_pk, :canonical, :joined
    end
  end
end
