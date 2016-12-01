# encoding: utf-8
# frozen_string_literal: true

require 'dry-initializer'
require 'uber/delegates'

# Chainable interface for lazy filtering

module ROM
  module Ldap
    class Lookup < ::Hash

      extend Dry::Initializer::Mixin
      param :relation
      param :filter

      extend Uber::Delegates
      delegates :relation, :search, :__new__
      delegates :filter,   :chain
      delegates :search!,  :as, :order, :to_a, :one, :one!

      def search!
        __new__(dataset)
      end

      def dataset
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
