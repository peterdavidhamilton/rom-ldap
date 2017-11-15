require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/directory/ldif'
require 'rom/ldap/dataset/dsl'

module ROM
  module LDAP
    # Method chaining class to build search criteria.
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

      param :source,
        reader: :private,
        type: Dry::Types['strict.string']

      option :base,
        reader: :private,
        type: Dry::Types['strict.string']

      option :criteria,
        reader: :private,
        type: Dry::Types['strict.array'],
        default: -> { [] }

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
        {
          base:   base,
          source: source,
          query:  query,
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

      # Sends methods like one! and map_to to the result array
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
      # private :each

      # Respond to repository methods by first calling #each
      #
      alias as each
      alias map_to each
      alias map_with each
      alias one! each
      alias one each
      alias to_a each
      alias with each

      # Inspect dataset revealing current filter criteria
      #
      # @return [String]
      #
      # @api public
      def inspect
        %(<##{self.class} search="#{filter_string}" base="#{base}">)
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

      # @return [Integer]
      #
      # @api public
      def total
        results = directory.total(query)
        reset!
        results
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

      # Convert the full query to an LDAP filter string
      #
      # @return [String]
      #
      # @api public
      def filter_string
        Functions[:to_ldap][query]
      end

      private

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
        Functions[:to_ast][source]
      end

      # @return [Array<Hash>]
      #
      # @api private
      def search(&block)
        results = directory.search(query, base: base, &block)
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
