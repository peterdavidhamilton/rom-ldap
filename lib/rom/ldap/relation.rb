require 'rom/ldap/types'
require 'rom/ldap/schema'
require 'rom/ldap/dataset'
require 'rom/ldap/attribute'
require 'rom/ldap/relation/reading'
require 'rom/ldap/relation/writing'
require 'rom/ldap/relation/exporting'
require 'rom/ldap/transaction'

module ROM
  module LDAP
    class Relation < ROM::Relation
      adapter :ldap

      include LDAP
      include Reading
      include Writing
      include Exporting

      extend Notifications::Listener

      # Set dataset search base value to be the default or class specific.
      subscribe('configuration.relations.schema.set', adapter: :ldap) do |event|
        relation = event[:relation]
        relation.dataset { with(base: relation.base || directory.base) }
      end

      # @api private
      def initialize(dataset, schema:, **)
        dataset = dataset.with(attrs: schema.map(&:name)) if dataset.is_a?(Dataset)
        super
      end


      defines :base
      defines :branches

      branches EMPTY_HASH

      schema_class      LDAP::Schema
      schema_attr_class LDAP::Attribute
      schema_inferrer   LDAP::Schema::Inferrer.new.freeze
      schema_dsl        LDAP::Schema::DSL

      forward(*Dataset.dsl)

      # Fallsback to :entry_dn operational value.
      #
      # @return [Symbol]
      #
      # @api public
      def primary_key
        attribute = schema.find(&:primary_key?)

        if attribute
          attribute.alias || attribute.name
        else
          :entry_dn
        end
      end


      # Expose the search base currently in use.
      #
      # @return [String] current base
      #
      # @api public
      def base
        dataset.opts[:base]
      end

      # Current dataset in LDAP filter format.
      #
      # @return [String]
      #
      # @api public
      def to_filter
        dataset.opts[:filter]
      end

      # @api public
      def self.associations
        schema.associations
      end

      # @return [Relation]
      #
      # @api public
      def assoc(name)
        associations[name].call
      end

      # @return [Relation]
      #
      # @api public
      def project(*names)
        with(schema: schema.project(*names))
      end

      # @return [Relation]
      #
      # @api public
      def exclude(*names)
        with(schema: schema.exclude(*names))
      end

      # @yield [t] Transaction
      #
      # @return [Mixed]
      #
      # @api public
      def transaction(opts = EMPTY_OPTS, &block)
        Transaction.new(dataset.directory).run(opts, &block)
      end

    end
  end
end
