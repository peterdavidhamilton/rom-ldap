# encoding: utf-8
# frozen_string_literal: true

require 'rom/schema'
# require 'rom/support/constants'

module ROM
  module Ldap
    class Schema < ROM::Schema

      def initialize(*)
        # binding.pry
        super # returned {}
      end

      # @api private
      def finalize!(*)
        # binding.pry

        # super returned
        #<ROM::Ldap::Schema name=ROM::Relation::Name(entries on persistence_relations_people) attributes=[] associations=#<ROM::AssociationSet elements={}>>

        super do

        end
      end
    end
  end
end
