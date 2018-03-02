require 'rom/ldap/types'
require 'rom/ldap/schema'
require 'rom/ldap/wrap'
require 'rom/ldap/dataset'
require 'rom/ldap/attribute'
require 'rom/ldap/transaction' # WIP
require 'rom/ldap/relation/reading'
require 'rom/ldap/relation/writing'
require 'rom/ldap/relation/exporting'

module ROM
  module LDAP
    class Relation < ROM::Relation
      adapter :ldap

      include LDAP
      include Reading
      include Writing
      include Exporting

      extend Notifications::Listener

      subscribe('configuration.relations.schema.set', adapter: :ldap) do |event|
        # schema   = event[:schema]
        relation = event[:relation]

        relation.dataset do
          # puts to_ldif
          self # <ROM::LDAP::Dataset filter='(gidnumber=1050)'>
        end
      end

      subscribe('configuration.relations.dataset.allocated', adapter: :ldap) do |event|
        event[:dataset].opts[:ldap_string]
      end

      #
      # LDAP specific class attributes.
      #
      defines :base
      defines :branches
      defines :groups
      defines :users

      branches EMPTY_HASH
      groups   '(|(objectClass=group)(objectClass=groupOfNames))'.freeze
      users    '(|(objectClass=inetOrgPerson)(objectClass=user))'.freeze

      schema_class      LDAP::Schema
      schema_attr_class LDAP::Attribute
      schema_inferrer   LDAP::Schema::Inferrer.new.freeze
      schema_dsl        LDAP::Schema::DSL
      wrap_class        LDAP::Wrap

      forward(*Dataset.dsl)

      def primary_key
        attribute = schema.find(&:primary_key?)

        if attribute
          attribute.alias || attribute.name
        else
          :dn
        end
      end

      # @yield [t] Transaction
      #
      # @return [Mixed]
      #
      # @api public
      def transaction(opts = EMPTY_HASH, &block)
        binding.pry
        Transaction.new(dataset.directory).run(opts, &block)
      end

      # Current dataset in LDAP filter format.
      #
      # @return [String]
      #
      # @api public
      def ldap_string
        dataset.opts[:ldap_string]
      end

      # Current dataset in abstract query format.
      #
      # @return [String]
      #
      # @api public
      def query_ast
        dataset.opts[:query_ast]
      end

      # Original dataset in LDAP filter format.
      #
      # @return [String]
      #
      # @api public
      def source_filter
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

      def project(*names)
        with(schema: schema.project(*names.flatten))
      end

      # def exclude(*names)
      #   with(schema: schema.exclude(*names.flatten))
      # end

      # def rename(mapping)
      #   with(schema: schema.rename(mapping))
      # end

      # def prefix(prefix)
      #   with(schema: schema.prefix(prefix))
      # end

      # def wrap(prefix = dataset.name)
      #   with(schema: schema.wrap(prefix))
      # end

    end
  end
end
