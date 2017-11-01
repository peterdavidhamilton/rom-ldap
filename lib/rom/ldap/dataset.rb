require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/dataset/query_dsl'
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

      param  :api,      reader: :private
      param  :filter,   reader: :private # original dataset table name
      option :criteria, reader: :private, default: proc { {} }

      option :offset, reader: false, optional: true
      option :limit,  reader: false, optional: true


      # @api public
      def opts
        Hash[
          offset: @offset,
          limit: @limit,
          criteria: @criteria,
          pagination: paginated?
        ]
      end

      # @return [ROM::LDAP::Dataset, self]
      #
      # @param args [Hash] New arguments to chain.
      #
      # @api private
      def merge!(args, &block)
        @criteria = Functions[:deep_merge][criteria, {"_#{__callee__}" => args}]
        self
      end

      private :merge!

      QueryDSL.query_methods.each do |meth|
        alias_method meth, :merge!
      end

      # OPTIMIZE:
      # Strange return structs to mirror Sequel behaviour for rom-sql
      #
      # @example
      #   api.db.db.database_type => :apacheds
      #
      # @public
      def db
        ::OpenStruct.new(db: ::OpenStruct.new(database_type: api.directory_type) )
      end


      # @return [ROM::LDAP::Dataset, self]
      #
      # @param offset [Integer] Integer value to start pagination range.
      #
      # @api public
      def offset(offset)
        @offset = offset
        self
      end

      # @return [ROM::LDAP::Dataset, self]
      #
      # @param limit [Integer] Integer value to calculate pagination range end.
      #
      # @api public
      def limit(limit)
        @limit = limit
        self
      end

      # @return [Enumberator::Lazy, Array]
      #
      # @api public
      def each(*args, &block)
        results = search.lazy # search(scope: nil)
        reset!
        results = paginate(results) if paginated?

        block_given? ? results.send(__callee__, *args, &block) : results
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


      # Combine original relation filter with search criteria
      #
      # @return [String]
      #
      # @api public
      def filter_string
        query_dsl[criteria, filter]
      end

      # Inspect dataset revealing current filter criteria
      #
      # @return [String]
      #
      # @api public
      def inspect
        %(<##{self.class} filter="#{filter_string}">)
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
        each.size
      end

      # @return [Integer]
      #
      # @api public
      def total
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


      private

      def query_dsl
        @query_dsl ||= QueryDSL.new
      end

      # Reset the current criteria
      #
      # @return [ROM::LDAP::Dataset]
      #
      # @api private
      def reset!
        @criteria = {}
        self
      end

      # @api private
      def paginate(results)
        results.to_a[page_range] || EMPTY_ARRAY
      end

      # @api private
      def page_range
        @offset..(@offset + @limit - 1) if paginated?
      end

      # @api private
      def paginated?
        !!@limit && !!@offset
      end

      # @return [Array<Hash>]
      #
      # @api private
      def search(scope: nil, &block)
        results = api.search(filter_string, scope: scope, &block)
        reset!
        results
      end

    end
  end
end
