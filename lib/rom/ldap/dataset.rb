require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/dataset/reading'
require 'rom/ldap/dataset/writing'
require 'rom/ldap/dataset/query_dsl'

# Hash#except
using ::Compatibility

module ROM
  module LDAP
    #
    # @option :directory [Directory] Directory object
    #
    # @option :filter [String] Relation name.
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
    # @option :entries [Array] Tuples returned from directory.
    #
    # @api private
    class Dataset
      extend Initializer
      include Enumerable

      option :directory

      option :filter,
        reader:   false,
        type:     Dry::Types['string']

      option :base,
        reader:   :private,
        type:     Dry::Types['strict.string'],
        default:  -> { EMPTY_STRING }

      option :criteria,
        reader:   :private,
        type:     Dry::Types['strict.array'],
        default:  -> { EMPTY_ARRAY }

      option :offset,
        reader:   :private,
        optional: true,
        type:     Dry::Types['strict.integer']

      option :limit,
        reader:   :private,
        optional: true,
        type:     Dry::Types['strict.integer']

      option :sort_attr,
        reader:   :private,
        optional: true,
        type:     Dry::Types['strict.array']

      option :entries,
        reader:   false,
        optional: true,
        type:     Dry::Types['strict.array']

      include QueryDSL
      include Reading
      include Writing

      # Collection of Dataset::QueryDSL module methods.
      #   Used by Relation to forward methods to Dataset.
      #
      # @return [Array<Symbol>]
      #
      # @example
      #   # => %i{where has lt begins excudes present}
      #
      def self.dsl
        QueryDSL.public_instance_methods(false)
      end

      # Initialise a new class overriding options.
      #
      # @return [ROM::LDAP::Dataset]
      #
      # @param overrides [Hash] Alternative options
      #
      # @api public
      def with(overrides)
        self.class.new(options.merge(overrides))
      end

      # @return [Hash] internal options
      #
      # @api public
      def opts
        options
          .except(:directory)
          .merge(query_ast: query_ast, ldap_string: ldap_string)
          .freeze
      end

      # FIXME: selected attributes in query
      #
      # @return [Dataset]
      #
      # @api public
      def select(*args)
        with(entries: map { |e| e.select(*args) })
      end

      # @todo Descibe this method
      #
      # @return [Array<Directory::Entry>]
      #
      # @api public
      def each(*args, &block)
        return entries.to_enum unless block_given?

        if paginated?
          entries[page_range].each(*args, &block)
        else
          entries.each(*args, &block)
        end
      end

      def map(key = nil, &block)
        if key
          # each.map { |e| e.select(key) }.map(&block)
          each.map { |e| e[key] }.map(&block)
        else
          each.map(&block)
        end
      end

      # Inspect dataset revealing current filter and base.
      #
      # @return [String]
      #
      # @api public
      def inspect
        %(#<#{self.class}: base="#{base}" #{query_ast}>)
      end

      private

      # Update the criteria
      #
      # @api private
      def chain(*exprs)
        if options[:criteria].empty?
          with(criteria: exprs)
        else
          with(criteria: [:con_and, [options[:criteria], exprs]])
        end
      end

      # Convert the full query to an LDAP filter string
      #
      # @return [String]
      #
      # @api private
      def ldap_string
        Functions[:to_ldap].(query_ast)
      end

      # Combine original relation dataset name (LDAP filter string)
      #   with search criteria (AST).
      #
      # @return [String]
      #
      # @api private
      def query_ast
        if criteria.empty?
          filter_ast
        else
          [:con_and, [filter_ast, criteria]]
        end
      end

      # Convert the relation's source filter string to a query AST.
      #
      # @return [Array]
      #
      # @api private
      def filter_ast
        Functions[:to_ast].(options[:filter])
      end

      # Populate with a directory search or iterate over existing @entries.
      #
      # @return [Array<Hash>]
      #
      # @api private
      def entries
        results = options[:entries] || directory.search(query_ast, base: base, sort: sort_attr)
        options[:criteria] = []
        options[:entries]  = nil
        results
      end

      # @api private
      def page_range
        offset..(offset + limit - 1)
      end

      # @api private
      def paginated?
        limit && offset
      end
    end
  end
end
