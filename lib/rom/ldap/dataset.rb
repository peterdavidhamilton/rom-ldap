require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/query_dsl'
require 'rom/ldap/directory/ldif'

module ROM
  module LDAP
    class Dataset
      extend  Initializer
      include Enumerable
      include Dry::Equalizer(:criteria)

      param  :directory, reader: :private
      param  :filter,    reader: :private
      option :criteria,  reader: :private, default: proc { {} }
      option :offset,    reader: false, optional: true
      option :limit,     reader: false, optional: true

      # @api public
      def opts
        Hash[
          offset:     @offset,
          limit:      @limit,
          criteria:   @criteria,
          pagination: paginated?
        ]
      end

      # @return [ROM::LDAP::Dataset, self]
      #
      # @param args [Hash] New arguments to chain.
      #
      # @api private
      def merge!(args)
        @criteria = Functions[:deep_merge][criteria, { "_#{__callee__}" => args }]
        self
      end

      private :merge!

      QueryDSL.query_methods.each do |meth|
        alias_method meth, :merge!
      end

      # OPTIMIZE: Strange return structs to mirror Sequel behaviour for rom-sql
      #
      # @example
      #   api.db.db.database_type => :apacheds
      #
      # @api public
      def db
        ::OpenStruct.new(db: ::OpenStruct.new(database_type: directory.type))
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

      # @return [Enumerator::Lazy, Array]
      #
      # @api public
      def each(*args, &block)
        results = search.lazy
        reset!
        results = paginate(results) if paginated?
        block_given? ? results.send(__callee__, *args, &block) : results
      end

      # Respond to repository methods by first calling #each
      #
      alias as each
      alias map_to each
      alias map_with each
      alias one! each
      alias one each
      alias to_a each
      alias with each

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
        directory.bind_as(filter: filter_string, password: password)
      end

      # @return [Boolean]
      #
      # @api public
      def any?
        each.any?
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
        results = directory.total(filter_string)
        reset!
        results
      end

      # @return [Boolean]
      #
      # @api public
      def include?(key)
        results = directory.include?(filter_string, key)
        reset!
        results
      end

      # @param tuple [Hash]
      #
      # @return [Boolean]
      #
      # @api public
      def add(tuple)
        directory.add(tuple)
      end

      #
      # @api public
      def modify(tuples, args)
        tuples.map { |t| directory.modify(*t[:dn], args.map { |k, v| [:replace, k, v] }) }
      end

      #
      # @api public
      def delete(tuples)
        tuples.map { |t| directory.delete(*t[:dn]) }
      end

      # Output the dataset as an LDIF string.
      #
      # @return [String]
      #
      # @api public
      def to_ldif
        Directory::LDIF.new(each, comments: Time.now).to_ldif
      end

      private

      # @return [Array<Hash>]
      #
      # @api private
      def search(&block)
        results = directory.search(filter_string, &block)
        reset!
        results
      end

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
    end
  end
end
