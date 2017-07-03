require 'rom/ldap/functions'
require 'rom/ldap/dataset/dsl'
require 'rom/ldap/dataset/api'

module ROM
  module Ldap
    class Dataset
      include Enumerable

      DEFAULT_CRITERIA = {
        '_where' => { objectclass: 'inetorgperson' }
      }.freeze

      attr_reader :api, :criteria, :generator

      def initialize(api)
        @api = api
        @criteria ||= {}
        @generator = DSL.new
      end

      private :api, :criteria, :generator

      def build(args, &block)
        new_criteria = {"_#{__callee__}" => args}
        @criteria    = Ldap::Functions[:deep_merge][criteria, new_criteria]
        self
      end

      private :build

      DSL.query_methods.each do |m|
        alias_method m, :build
      end

      # hit directory,
      # reset criteria,
      # return an lazy enumerator unless block
      # iterate over results,
      # pass on relation methods
      #
      def each(*args, &block)
        results = search
        reset!
        return results.to_enum.lazy unless block_given?
        results.each(&block).send(__callee__, *args)
      end

      # Respond to repository methods by first calling #each
      #
      # [:as, :map_to, :map_with, :one!, :one, :to_a, :with].each do |m|
      #   alias_method m, :each
      # end
      alias_method :as,       :each
      alias_method :map_to,   :each
      alias_method :map_with, :each
      alias_method :one!,     :each
      alias_method :one,      :each
      alias_method :to_a,     :each
      alias_method :with,     :each

      # Reset the current criteria
      #
      # @return [ROM::Ldap::Dataset]
      #
      # @public
      #
      def reset!
        @criteria = {}
        self
      end

      # query string for current criteria
      # fallback to all results
      # object
      # Net::LDAP::Filter
      #
      def to_filter
        @criteria = DEFAULT_CRITERIA if criteria.empty?
        generator[criteria]
      end

      # reveal current filter criteria
      # string
      #
      def inspect
        "#<#{self.class.name}:#{self.object_id} filter: #{to_filter} >"
      end

      #
      #
      def search
        api.search(to_filter)
      end

      private :search

      #
      #
      def to_ldif
        api.raw(to_filter).to_ldif
      end

    end

  end
end
