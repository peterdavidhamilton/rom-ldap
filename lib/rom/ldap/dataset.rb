require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/dataset/dsl'
require 'rom/ldap/dataset/instance_methods'

module ROM
  module LDAP
    # Method chaining class to build search criteria,
    #   finalised and reset once #each is called.
    #
    # @param directory [Directory] Directory object
    #
    # @param source [String] Relation name.
    #   @example => "(&(objectClass=person)(uidNumber=*))"
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
      extend Initializer
      include Enumerable

      param :directory

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
      include InstanceMethods

      # Used by Relation to forward methods to dataset
      #
      def self.dsl
        DSL.public_instance_methods(false)
      end

      # Raw filter search - overload filter
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

      # Iterate over @entries or populate with a directory search.
      # Reset @criteria and @entries.
      #
      # @return [Enumerator::Lazy<Directory::Entry>]
      #
      # @api public
      def each(*args, &block)
        results = @entries ||= search.lazy
        @entries = nil
        @criteria = []

        if paginated?
          results = results.to_a[page_range].lazy || EMPTY_ARRAY.lazy
        end

        if block_given?
          results.each(*args, &block)
        else
          results
        end
      end

      # Find by Distinguished Name
      #
      # @param dns [String, Array<String>]
      #
      # @return [Dataset]
      #
      # @api public
      def fetch(dns)
        @entries = Array(dns).flat_map { |dn| directory.by_dn(dn) }
        self
      end

      # @return [Dataset]
      #
      # @api public
      def select(*args)
        @entries = each.map { |entry| entry.select(*args) }
        self
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
        %(#<#{self.class}: "#{filter}" base="#{@base}">)
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
        directory.search(query, base: @base, &block)
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
