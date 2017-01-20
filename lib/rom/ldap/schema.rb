# encoding: utf-8
# frozen_string_literal: true

require 'rom/schema'
require 'rom/types'

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

      # def finalize!({gateway: xxx, relations: xxx })
        # binding.pry
        # super returned
        #<ROM::Ldap::Schema name=ROM::Relation::Name(entries on persistence_relations_people) attributes=[] associations=#<ROM::AssociationSet elements={}>>

        # binding.pry
        super do
          # binding.pry
          # rename({})
        end
      end

      def call(relation)
        relation.new(relation.dataset.select(*self), schema: self)
      end


    end



    # AttributeSchema = Dry::Validation.Schema do
    #   required(:dn).filled #(format?: /\A[+-]?\d+\Z/)
    #   required(:uid).filled(min_size?: 3)
    #   required(:cn).filled
    #   required(:uid).filled
    #   required(:givenname).filled
    #   required(:sn).filled
    #   required(:objectclass).filled #value(type?: Types::Field)
    #   optional(:mail).filled #value(type?: Types::Field)
    # end

  end
end

# breaks
# require 'rom/ldap/schema/dsl'


