# encoding: utf-8
# frozen_string_literal: true

require 'rom/schema'
require 'rom/ldap/types'

module ROM
  module Ldap
    class Schema < ROM::Schema

      def finalize!(gateway:, relations:)
        # binding.pry
        # super returned
        #<ROM::Ldap::Schema name=ROM::Relation::Name(entries on persistence_relations_people) attributes=[] associations=#<ROM::AssociationSet elements={}>>

        super do
          # binding.pry
          # rename({})
        end
      end

      def call(relation)
        # binding.pry
        relation.new(relation.dataset.select(*self), schema: self)
      end


    end

  end
end

# require 'rom/ldap/schema/dsl'
