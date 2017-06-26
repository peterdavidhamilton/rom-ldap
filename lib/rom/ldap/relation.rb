# encoding: utf-8
# frozen_string_literal: true

require 'rom/ldap/types'
require 'rom/ldap/schema'
require 'rom/ldap/schema/inferrer'
require 'rom/ldap/lookup' # this is DSL
require 'rom/ldap/dataset'
require 'rom/ldap/relation/filter'
require 'rom/ldap/relation/reading'
require 'rom/ldap/relation/writing'

module ROM
  module Ldap
    class Relation < ROM::Relation
      adapter :ldap

      include Reading
      include Writing

      schema_class      Ldap::Schema
      schema_attr_class Ldap::Attribute
      schema_inferrer   ROM::Ldap::Schema::Inferrer.new.freeze
      # wrap_class      SQL::Wrap


      # fetch and by_pk are prerequisites for using changesets
      def fetch(dn)
        where(dn: dn)
      end

      alias by_pk fetch

      def adapter
        Gateway.instance
      end

      def directory
        adapter.connection
      end

      def host
        directory.host
      end

      def base
        directory.base
      end

      def auth
        directory.instance_variable_get(:@auth)
      end

      # @return Dataset from a single filter
      #
      # @api public
      def op_status
        directory.get_operation_result
      end


      # Other adapters call class level forward
      # forward :join, :project, :restrict, :order


      # @return Dataset from a single filter
      #
      # @api public
      def search(filter)
        Dataset.new[filter]
      end

      # @return Dataset from a chain of filters
      #
      # @api public
      def lookup
        Lookup.new(self, Filter.new)
      end







      def primary_key
        attribute = schema.find(&:primary_key?)

        if attribute
          attribute.alias || attribute.name
        else
          :id
        end
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
