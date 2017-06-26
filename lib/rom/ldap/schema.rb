# encoding: utf-8
# frozen_string_literal: true

require 'rom/schema'
require 'rom/ldap/types'

module ROM
  module Ldap
    class Schema < ROM::Schema

      # # Return a new schema with attributes marked as qualified
      # #
      # # @return [Schema]
      # #
      # # @api public
      # def qualified
      #   new(map(&:qualified))

      #   # qualified method used when attempting to aggregate from inside sql repo, this is called from Ldap::relation #qualified
      # end



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
