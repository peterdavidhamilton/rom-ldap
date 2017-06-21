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

      # @api private
      def finalize_attributes!(options = EMPTY_HASH)
        # binding.pry
        super
      end

      # @api private
      def finalize_associations!(relations:)
        # binding.pry
        super
      end



      def call(relation)
        relation.new(relation.dataset.select(*self), schema: self)
      end
    end
  end
end

# require 'rom/ldap/schema/dsl'
