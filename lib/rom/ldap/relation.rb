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

      # struct_namespace LDAP:Struct

      # GROUPS = '(|(objectClass=group)(objectClass=groupOfNames))'.freeze
      # USERS  = '(|(objectClass=inetOrgPerson)(objectClass=user))'.freeze

      defines :base
      # defines :filter

      # filter USERS

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
        event[:dataset].filter_string.to_s
      end

      schema_class      LDAP::Schema
      schema_attr_class LDAP::Attribute
      schema_inferrer   LDAP::Schema::Inferrer.new.freeze
      schema_dsl        LDAP::Schema::DSL

      forward(*QueryDSL.query_methods)

      def primary_key
        attribute = schema.find(&:primary_key?)

        if attribute
          attribute.alias || attribute.name
        else
          :id
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

      # Return raw query string
      #
      # @return [String]
      #
      # @api private
      def filter
        dataset.filter_string.to_s
      end

      # @api private
      def self.associations
        schema.associations
      end

      # @return [Relation]
      #
      # @api public
      def assoc(name)
        associations[name].call
      end

      # available methods provided by DSL
      #
      # @return [Array<Symbol>]
      #
      # @api private
      def query_methods
        QueryDSL.query_methods.sort
      end
      private :query_methods


      # Compliments #root method with an alternative search base
      #
      # @api public
      def branch
        base(self.class.base)
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
