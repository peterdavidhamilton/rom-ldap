require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/dataset/reading'
require 'rom/ldap/dataset/writing'
require 'rom/ldap/dataset/query_dsl'

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
        type:     Dry::Types['strict.string']

      option :criteria,
        reader:   :private,
        type:     Dry::Types['strict.array'],
        default:  -> { [] }

      option :offset,
        reader:   :private,
        optional: true,
        type:     Dry::Types['strict.int']

      option :limit,
        reader:   :private,
        optional: true,
        type:     Dry::Types['strict.int']

      option :entries,
        reader:   false,
        optional: true,
        type:     Dry::Types['strict.array']


      include QueryDSL
      include Reading
      include Writing

      # Used by Relation to forward methods to dataset
      #
      def self.dsl
        QueryDSL.public_instance_methods(false)
      end

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
        options.except(:directory).merge(query_ast: query_ast, ldap_string: ldap_string).freeze
      end

      #
      #
      # @return [Array<Directory::Entry>]
      #
      # @api public
      def each(*args, &block)
        if paginated?
          entries[page_range].each(*args, &block)
        else
          entries.each(*args, &block)
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
        results = options[:entries] || directory.search(query_ast, base: base)
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
