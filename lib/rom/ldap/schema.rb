# encoding: utf-8
# frozen_string_literal: true

require 'rom/schema'
# require 'rom/support/constants'

module ROM
  module Ldap
    class Schema < ROM::Schema

      def initialize(*)
        binding.pry
        super
      end

      # @api private
      def finalize!(*)
        binding.pry
        super do

        end
      end
    end
  end
end
