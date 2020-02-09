require 'rom/initializer'
require 'rom/ldap/functions'

require 'rom/ldap/dataset/conversion'
require 'rom/ldap/dataset/persistence'
require 'rom/ldap/dataset/dsl'

module ROM
  module LDAP
    #
    # @api private
    class Dataset

      extend Initializer
      include Enumerable

      # Directory instance
      #
      # @!attribute [r] directory
      #   @return [Directory]
      option :directory

      # LDAP filter defined in relation schema.
      #
      # @!attribute [r] name
      #   @return [String] Valid LDAP filter filter string.
      option :name, type: Types::Filter, reader: :private

      # Valid Distinguished Name. A relation class value or the gateway default.
      #
      # @!attribute [r] base
      #   @return [String] Set when initializing a relation
      option :base, type: Types::DN, reader: :private, default: -> { directory.base }

      #
      # @!attribute [r] criteria
      #   @return [Array] Query AST
      option :criteria, type: Types::Strict::Array, reader: :private, default: -> { EMPTY_ARRAY }

      #
      # @!attribute [r] direction
      #   @return [Symbol]
      option :direction, type: Types::Direction, reader: :private, default: -> { :asc }

      #
      # @!attribute [r] offset
      #   @return [Integer] Pagination per_page(20).
      option :offset, type: Types::Strict::Integer, reader: :private, optional: true

      # @option :limit [Integer] Pagination page(1).
      #
      option :limit, type: Types::Strict::Integer, reader: :private, optional: true

      # @option :random [TrueClass] Switch for randomisation
      #
      option :random, type: Types::Strict::Bool, reader: :private, default: -> { false }

      # Attributes to return. Needs to be set to the projected schema.
      #
      option :attrs, type: Types::Strict::Array, reader: :private, optional: true

      # @option :aliases [Array]
      #
      option :aliases, type: Types::Strict::Array, reader: :private, default: -> { EMPTY_ARRAY }

      # @option :sort_attrs [String,Symbol] Attribute name(s) to sort by.
      #
      option :sort_attrs, type: Types::Strict::Array, reader: :private, optional: true

      include DSL
      include Persistence
      include Conversion

      # Collection of Dataset::DSL module methods.
      #   Used by Relation to forward methods to Dataset.
      #
      # @return [Array<Symbol>]
      #
      # @example
      #   # => %i{equal has lt begins excludes present}
      #
      def self.dsl
        DSL.public_instance_methods(false)
      end

      # Dataset#where
      alias where equal

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
        options.merge(ast: to_ast, filter: to_filter).freeze
      end

      # Iterate over the entries return from the server.
      #
      # @return [Array <Directory::Entry>]
      # @return [Enumerator <Directory::Entry>]
      #
      # @api public
      def each(*args, &block)
        results = paginated? ? entries[page_range] : entries
        results = results.sort_by { rand } if random
        results = results.reverse_each if reversed?
        results = results.map { |e| apply_aliases(e) } if aliases.any?

        block_given? ? results.each(*args, &block) : results.to_enum
      end

      # Iterate over each entry or one attribute of each entry.
      #
      # @return [Mixed]
      #
      # @api public
      def map(attr = nil, &block)
        each.map { |entry| attr ? entry[attr] : entry }.map(&block)
      end

      # Inspect dataset revealing current ast and base.
      #
      # @return [String]
      #
      # @api public
      def inspect
        %(#<#{self.class}: base="#{base}" #{to_ast} />)
      end

      # Wildcard search on multiple attributes.
      #
      # @example
      #   dataset.grep([:givenname, :sn], 'foo').opts[:criteria] =>
      #     [:con_or, [[:op_eql, :givenname, "*foo*"], [:op_eql, :sn, "*foo*"]]]
      #
      #
      # @see Relation::Reading#grep
      #
      # @param attrs [Array<Symbol>] schema attribute names
      #
      # @param value [String] search parameter
      #
      # @return [Relation]
      #
      # @api public
      def grep(attrs, value)
        new_criteria = attrs.map do |attr|
          match_dsl([[attr, value]], left: WILDCARD, right: WILDCARD)
        end
        join(new_criteria, :con_or)
      end

      # @see Relation#where
      #
      # Combine AST criteria - use AND by default
      #
      # @param new_criteria [Array]
      # @param constructor  [Symbol]
      #
      # @return [Relation]
      #
      # @api public
      def join(new_criteria, constructor = :con_and)
        new_chain = join_dsl(constructor, new_criteria)

        # check because RestrictionDSL sometimes offers empty criteria
        if new_chain.empty?
          self
        else
          chain(*new_chain)
        end
      end

      # Validate the password against the filtered user.
      #
      # @param password [String]
      #
      # @return [Boolean]
      #
      # @api public
      def bind(password)
        directory.bind_as(filter: to_ast, password: password)
      end

      # Handle different string output formats
      #   i.e. DSML, LDIF, JSON, YAML, MessagePack.
      #
      # @return [Hash, Array<Hash>]
      #
      def export
        results = map(&:canonical)
        results.one? ? results.first : results
      end

      # Unrestricted count of every entry under the search base
      #   with the domain entry discounted.
      #
      # @return [Integer]
      #
      # @api public
      def total
        directory.base_total - 1
      end

      private

      # Communicate with LDAP servers.
      #   @see Connection::SearchRequest for #query keywords defintion.
      #
      # @return [Array<Hash>] Populate with a directory search.
      #
      # @api private
      def entries
        results =
          directory.query(
            filter: to_ast,
            base: base,
            attributes: renamed_select,
            sorted: renamed_sort,
            max: limit,
            reverse: reversed?
          )

        options[:criteria] = []
        results
      end

      # @api private
      def renamed_select
        directory.canonical_attributes(attrs) if attrs
      end

      # @api private
      def renamed_sort
        directory.canonical_attributes(sort_attrs) if sort_attrs
      end

      # @return [Range]
      #
      # @api private
      def page_range
        offset..(offset + limit - 1)
      end

      # @api private
      def paginated?
        limit && offset
      end

      # @api private
      def reversed?
        direction.eql?(:desc)
      end

      def apply_aliases(entry)
        Functions[:rename_keys][alias_map, entry].invert
      end

      def alias_map
        { dn: :dn }.merge(attrs.zip(aliases).to_h)
      end

    end
  end
end
