require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/dataset/dsl'
require 'rom/ldap/dataset/instance_methods'

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


      # @return [Hash] internal options
      #
      # @api public
      def opts
        options.merge(query_ast: query_ast, ldap_string: ldap_string).freeze
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

      # @return [ROM::LDAP::Dataset]
      #
      # @param overrides [Hash] Alternative options
      #
      # @api public
      def with(overrides)
        self.class.new(options.merge(overrides))
      end


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


      # Find by Distinguished Name(s)
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
        @entries = map { |entry| entry.select(*args) }
        self
      end

      # Validate the password against the filtered user.
      #
      # @param password [String]
      #
      # @return [Boolean]
      #
      # @api public
      def bind(password)
        directory.bind_as(filter: query, password: password)
      end


      # Inspect dataset revealing current filter and base.
      #
      # @return [String]
      #
      # @api public
      def inspect
        %(#<#{self.class}: "#{filter}" base="#{base}">)
      end

      private

      # Convert the full query to an LDAP filter string
      #
      # @return [String]
      #
      # @api private
      def ldap_string
        Functions[:to_ldap][query_ast]
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
        Functions[:to_ast][@filter]
      end

      # Populate with a directory search or iterate over existing @entries.
      #
      # @return [Array<Hash>]
      #
      # @api private
      def entries
        results   = @entries || directory.search(query_ast, base: base)
        @criteria = []
        @entries  = nil
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
