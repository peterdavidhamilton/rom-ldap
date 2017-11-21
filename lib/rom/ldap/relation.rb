require 'rom/ldap/types'
require 'rom/ldap/schema'
require 'rom/ldap/dataset'
require 'rom/ldap/attribute'
require 'rom/ldap/transaction'
require 'rom/ldap/relation/reading'
require 'rom/ldap/relation/writing'

module ROM
  module LDAP
    class Relation < ROM::Relation
      adapter :ldap

      include LDAP
      include Reading
      include Writing

      extend Notifications::Listener

      subscribe('configuration.relations.schema.set', adapter: :ldap) do |event|
        # schema   = event[:schema]
        relation = event[:relation]

        relation.dataset do
          # puts to_ldif
          self # <ROM::LDAP::Dataset filter='(gidnumber=1050)'>

          # db => OpenStruct { :db => OpenStruct { :database_type => :apacheds } }
        end
      end

      subscribe('configuration.relations.dataset.allocated', adapter: :ldap) do |event|
        event[:dataset].opts[:filter]
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

      # struct_namespace LDAP:Struct
      schema_class      Schema
      schema_attr_class Attribute
      schema_inferrer   Schema::Inferrer.new.freeze
      schema_dsl        Schema::DSL
      forward           *Dataset.dsl

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
        Transaction.new(dataset.db).run(opts, &block)
      end

      # Current dataset in LDAP filter format.
      #
      # @return [String]
      #
      # @api public
      def filter
        dataset.opts[:filter]
      end

      # Current dataset in abstract query format.
      #
      # @return [String]
      #
      # @api public
      def query
        dataset.opts[:query]
      end


      # Original dataset in LDAP filter format.
      #
      # @return [String]
      #
      # @api public
      def source
        dataset.opts[:source]
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

      def exclude(*names)
        with(schema: schema.exclude(*names.flatten))
      end

      def rename(mapping)
        with(schema: schema.rename(mapping))
      end

      def prefix(prefix)
        with(schema: schema.prefix(prefix))
      end

      def wrap(prefix = dataset.name)
        with(schema: schema.wrap(prefix))
      end
    end
  end
end
