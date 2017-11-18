require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/directory/ldif'
require 'rom/ldap/dataset/dsl'

module ROM
  module LDAP
    # Method chaining class to build search criteria,
    #   finalised and reset once #each is called.
    #
    # @param directory [Directory] Directory object
    #
    # @param source [String] Relation name.
    #   @example => "(&(objectclass=person)(uidnumber=*))"
    #
    # @option :limit [Integer] Pagination page(1).
    #
    # @option :offset [Integer] Pagination per_page(20).
    #
    # @option :base [String] Default search base defined in ROM.configuration.
    #
    # @option :criteria [Array] Initial query criteria AST.
    #
    # @api private
    class Dataset
      extend  Initializer
      include Enumerable
      include Dry::Equalizer(:criteria)

      param :directory, reader: :private

      param :source,
        reader:   false,
        type:     Dry::Types['strict.string']

      option :base,
        reader:   false,
        type:     Dry::Types['strict.string']

      option :offset,
        reader:   false,
        optional: true,
        type:     Dry::Types['strict.int']

      option :limit,
        reader:   false,
        optional: true,
        type:     Dry::Types['strict.int']

      option :criteria,
        reader:   :private,
        type:     Dry::Types['strict.array'],
        default:  -> { [] }

      # @api public
      def opts
        {
          base:   @base,
          source: @source,
          query:  query,
          filter: filter,
          offset: @offset,
          limit:  @limit
        }.freeze
      end

      # Methods that define the query interface.
      #
      include DSL

      # Used by Relation to forward methods to dataset
      #
      def self.dsl
        DSL.public_instance_methods(false)
      end


      # Raw filter search.
      # Temporarily replace dataset with new filter.
      #
      # @return [ROM::LDAP::Dataset]
      #
      # @param filter [String] Valid LDAP filter string
      #
      # @api public
      def call(filter)
        original  = @source
        @criteria = []
        @source   = filter
        results   = each
        @source   = original
        results
      end
      alias [] call

      # Mirror Sequel dataset behaviour for rom-sql relation compatibility.
      #
      # @example
      #   dataset.db.db.database_type => :apacheds
      #
      # @api public
      def db
        db = ::OpenStruct.new
        db[:database_type] = directory.type
        ::OpenStruct.new(db: db)
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

      # Initiate directory search and return some or all results before resetting criteria.
      #
      # @return [Enumerator::Lazy, Array]
      #
      # @api public
      def each(*args, &block)
        results = search.lazy
        reset!
        results = paginate(results) if paginated?
        block_given? ? results.send(__callee__, *args, &block) : results
      end

      # Respond to Relation methods by returning finalised search results.
      #
      alias as each
      alias map_to each
      alias map_with each
      alias one! each
      alias one each
      alias with each
      alias to_a each

      # Inspect dataset revealing current filter and base.
      #
      # @return [String]
      #
      # @api public
      def inspect
        %(<##{self.class} filter="#{filter}" base="#{@base}">)
      end

      # True if password binds for the filtered dataset
      #
      # @param password [String]
      #
      # @return [Boolean]
      #
      # @api public
      def authenticated?(password)
        directory.bind_as(filter: query, password: password)
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

      # Unrestricted count of every entry under the base with base entry deducted.
      #
      # @return [Integer]
      #
      # @api public
      def total
        directory.base_total - 1
      end

      # @return [Boolean]
      #
      # @api public
      def include?(key)
        results = directory.include?(query, key)
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

      # Convert the full query to an LDAP filter string
      #
      # @return [String]
      #
      # @api private
      def filter
        Functions[:to_ldap][query]
      end

      # Combine original relation dataset name (LDAP filter string)
      #   with search criteria (AST).
      #
      # @return [String]
      #
      # @api private
      def query
        return source_to_ast if criteria.empty?
        [:con_and, [source_to_ast, criteria]]
      end

      # Convert the relation's source filter string to a query AST.
      #
      # @return [Array]
      #
      # @api private
      def source_to_ast
        Functions[:to_ast][@source]
      end

      # @return [Array<Hash>]
      #
      # @api private
      def search(&block)
        results = directory.search(query, base: @base, &block)
        reset!
        results
      end

      # Reset the current criteria
      #
      # @return [ROM::LDAP::Dataset]
      #
      # @api private
      def reset!
        @criteria = []
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
