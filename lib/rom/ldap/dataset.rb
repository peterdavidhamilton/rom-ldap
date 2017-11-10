require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/filter/dsl'
require 'rom/ldap/directory/ldif'

module ROM
  module LDAP
    # Method chaining class to build search criteria.
    #   Passes criteria and orignal filter to the query DSL.
    #
    # @param filter [String] Relation name
    #   @example => "(&(objectclass=person)(uidnumber=*))"
    #
    # @option :limit [Integer] Pagination page(1)
    #
    # @option :offset [Integer] Pagination per_page(20)
    #
    # @option :base [String] Default search base defined in ROM.configuration
    #
    # @api private
    class Dataset
      extend  Initializer
      include Enumerable
      include Dry::Equalizer(:criteria)

      param :directory, reader: :private

      param :filter,
        reader: :private,
        type: Dry::Types['strict.string']

      option :base,
        reader: :private,
        type: Dry::Types['strict.string']

      option :criteria,
        reader: :private,
        type: Dry::Types['strict.hash'],
        default: proc { {} }

      option :offset,
        reader: false,
        optional: true,
        type: Dry::Types['strict.int']

      option :limit,
        reader: false,
        optional: true,
        type: Dry::Types['strict.int']

      # @api public
      def opts
        Hash[
          offset:     @offset,
          limit:      @limit,
          criteria:   @criteria,
          base:       @base,
          pagination: paginated?
        ]
      end

      # @return [ROM::LDAP::Dataset]
      #
      # @param args [Hash] New arguments to chain.
      #
      # @api private
      def chain!(args)
        @criteria = Functions[:deep_merge][criteria, { "_#{__callee__}" => args }]
        self
      end

      private :chain!

      # Merge criteria when the next DSL method is called
      #
      # @api private
      Filter::DSL.query_methods.each do |query_method|
        alias_method query_method, :chain!
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

      # @return [ROM::LDAP::Dataset]
      #
      # @param offset [Integer] Integer value to start pagination range.
      #
      # @api public
      def offset(offset)
        @offset = offset
        self
      end

      # @return [ROM::LDAP::Dataset]
      #
      # @param limit [Integer] Value to calculate pagination range end.
      #
      # @api public
      def limit(limit)
        @limit = limit
        self
      end

      # @return [ROM::LDAP::Dataset]
      #
      # @param base [String] Alternative search base.
      #
      # @api public
      def search_base(base)
        @base = base
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
        %(<##{self.class} filter="#{filter_string}" base="#{@base}">)
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
        @ldif ||= Directory::LDIF.new(each).to_ldif #(comment: Time.now)
      end

      private

      # @return [Array<Hash>]
      #
      # @api private
      def search(&block)
        results = directory.search(filter_string, base: base, &block)
        reset!
        results
      end

      def query_dsl
        @query_dsl ||= Filter::DSL.new
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
