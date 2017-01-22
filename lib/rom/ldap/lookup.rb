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

      # when finishing the method in repo that begins with lookup
      # it fires #search
      extend Forwardable
      def_delegators :search, :as, :order, :to_a, :one, :one!

      def search
        relation.new(dataset)
      end

      def dataset
        Dataset.new[filter.chain(self)]
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
