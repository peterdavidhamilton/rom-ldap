# encoding: utf-8
# frozen_string_literal: true

require 'dry-initializer'
require 'forwardable'

module ROM
  module Ldap
    class Lookup < ::Hash

      extend Dry::Initializer::Mixin
      param :relation
      param :filter

      extend Forwardable
      def_delegators :relation, :new, :search
      def_delegators :filter,   :chain
      def_delegators :search!,  :as, :order, :to_a, :one, :one!

      # delegate new to Relation
      def search!
        binding.pry
        # __new__(dataset)
        new(dataset)
      end

      # delegate search to Relation
      def dataset
        binding.pry
        search chain(self)
      end

      def build_lookup(key, *args)
        self[key] = args.one? ? args.first : args
        self
      end

      def method_missing(name, *args)
        args.any? ? build_lookup(name, *args) : super
      end

    end
  end
end
