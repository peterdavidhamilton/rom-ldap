# frozen_string_literal: true

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

      # @!method self.base
      #   Per relation override for the search base.
      #
      #   @overload base
      #     Return search base value
      #     @return [String]
      #
      #   @overload base(value)
      #     Set search base value
      defines :base

      # @!method self.branches
      #   Alternative search bases by name.
      #
      #   @overload branches
      #     Return hash of search branches.
      #     @return [Hash]
      #
      #   @overload branches(value)
      #     Set hash of search branches.
      defines :branches
      branches EMPTY_HASH

      extend Notifications::Listener

      subscribe('configuration.relations.schema.set', adapter: :ldap) do |event|
        relation = event[:relation]
        relation.dataset do
          # @return [Dataset]
          #
          # @override Dataset#base
          #
          # Set dataset search base using either class-level value or gateway config.
          with(base: relation.base || directory.base)
        end
      end

      schema_class      LDAP::Schema
      schema_attr_class LDAP::Attribute
      schema_inferrer   LDAP::Schema::Inferrer.new.freeze
      schema_dsl        LDAP::Schema::DSL

      forward(*Dataset.dsl)

      # Fallsback to 'entrydn' operational value.
      #
      # @return [Symbol]
      #
      # @api public
      def primary_key
        attribute = schema.find(&:primary_key?)

        if attribute
          attribute.alias || attribute.name
        else
          DEFAULT_PK
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

      # LDAP Transactions (LDAPTXN) is an experimental RFC.
      # The latest revision can be found at http://tools.ietf.org/rfc/rfc5805.txt
      #
      # @see https://directory.fedoraproject.org/docs/389ds/design/ldap-transactions.html
      #
      # @yield [t] Transaction
      #
      # @return [Mixed]
      #
      # @api public
      def transaction(opts = EMPTY_OPTS, &block)
        Transaction.new(dataset.directory).run(opts, &block)
      end

      #
      # @api private
      # def join(source_table, join_keys)
      #   binding.pry
      #   __registry__[source_table].where(join_keys)
      # end

    end
  end
end
