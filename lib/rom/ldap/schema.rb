# encoding: utf-8
# frozen_string_literal: true

require 'rom/schema'
require 'rom/ldap/types'

module ROM
  module Ldap
    class Schema < ROM::Schema

      # @api private
      # def initialize(*)
      #   binding.pry
      #   super
      # end

      # Return a new schema with attributes marked as qualified
      #
      # @return [Schema]
      #
      # @api public
      def qualified
        new(map(&:qualified))

        # qualified method used when attempting to aggregate from inside sql repo, this is called from Ldap::relation #qualified
      end


      # @api private
      def finalize_attributes!(options = EMPTY_HASH)

        # options { gateway: ROM::Ldap::Gateway, relations: (all 29) }

        # binding.pry
        super do
          initialize_primary_key_names
        end

        # super #gives
        #<ROM::Ldap::Schema name=ROM::Relation::Name(colleagues on (groupid=1025)) attributes=[] associations=#<ROM::AssociationSet elements={}>>
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

# require 'rom/ldap/schema/dsl'
