require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/dataset/dsl'
require 'rom/ldap/dataset/api'

module ROM
  module LDAP
    class Dataset

      # include ROM::EnumerableDataset

      # def self.row_proc
      #   -> tuple { tuple.each_with_object({}) { |(k,v), h| h[k.to_sym] = v } }
      # end

      extend  Initializer
      include Enumerable
      include Dry::Equalizer(:criteria)

      param  :api
      param  :table_name
      option :criteria,  default: proc { {} }
      option :generator, default: proc { DSL.new }

      private :api,
              :criteria,
              :generator,
              :table_name

      # OPTIMIZE:
      # Strange return structs to mirror Sequel behaviour for rom-sql
      #
      # @example
      #   api.db.db.database_type => :apacheds
      #
      def db
        ::OpenStruct.new(db: ::OpenStruct.new(database_type: api.directory_type) )
      end

      # @api private
      def build(args, &block)
        new_criteria = {"_#{__callee__}" => args}
        @criteria    = Functions[:deep_merge][criteria, new_criteria]
        self
      end
      private :build

      DSL.query_methods.each do |m|
        alias_method m, :build
      end

      # @param args [Range]
      #
      # @public
      def [](args)
        each.force[args] || EMPTY_ARRAY
      end

      # @api public
      def each(*args, &block)
        # results = search(scope: nil)
        results = search
        reset!
        return results.lazy unless block_given?
        # results.lazy.each(&block).send(__callee__, *args)
        results.lazy.send(__callee__, *args, &block)
      end

      # Respond to repository methods by first calling #each
      #
      alias_method :as,       :each
      alias_method :map_to,   :each
      alias_method :map_with, :each
      alias_method :one!,     :each
      alias_method :one,      :each
      alias_method :to_a,     :each
      alias_method :with,     :each

      # Reset the current criteria
      #
      # @return [ROM::LDAP::Dataset]
      #
      # @api private
      def reset!
        @criteria = {}
        self
      end
      private :reset!

      # Combine original relation filter with search criteria
      #  Fallback to original table on invalid filter
      #
      # @return [Net::LDAP::Filter]
      #
      # @api public
      def filter_string
        generator[criteria, table_name] or table_name
      end

      # Inspect dataset revealing current filter criteria
      #
      # @return [String]
      #
      # @api public
      def inspect
        %(#<#{self.class} filter='#{filter_string}'>)
      end

      # True if password binds for the filtered dataset
      #
      # @param password [String]
      #
      # @return [Boolean]
      #
      # @api public
      def authenticated?(password)
        api.bind_as(filter: filter_string, password: password)
      end

      # @return [Boolean]
      #
      # @api public
      def exist?
        results = api.exist?(filter_string)
        reset!
        results
      end

      # @return [Integer]
      #
      # @api public
      def count
        results = api.count(filter_string)
        reset!
        results
      end

      # @return [Boolean]
      #
      # @api public
      def include?(key)
        results = api.include?(filter_string, key)
        reset!
        results
      end

      # http://www.rubydoc.info/gems/ruby-net-ldap/Net%2FLDAP:add
      #
      # @param tuple [Hash]
      #
      # @return [Boolean]
      #
      # @api public
      def add(tuple)
        api.add(tuple)
      end

      # http://www.rubydoc.info/gems/ruby-net-ldap/Net%2FLDAP:modify
      #
      # @api public
      def modify(tuples, args)
        tuples.each do |t|
          api.modify(*t[:dn], args.map { |k, v| [:replace, k, v] })
        end
      end

      # http://www.rubydoc.info/gems/ruby-net-ldap/Net%2FLDAP:delete
      #
      # @api public
      def delete(tuples)
        tuples.each { |t| api.delete(*t[:dn]) }
      end

      # Output the dataset as an LDIF string.
      #
      # @return [String]
      #
      # @api public
      def to_ldif
        results = api.directory(filter: filter_string)
        reset!
        results.map(&:to_ldif).join("\n")
      end

      # @return [Array<Hash>]
      #
      # @api private
      def search(scope: nil, &block)
        api.search(filter_string, scope: scope, &block)
      end
      private :search

    end
  end
end
