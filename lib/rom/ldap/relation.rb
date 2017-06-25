# encoding: utf-8
# frozen_string_literal: true

require 'rom/ldap/types'
require 'rom/ldap/schema'
require 'rom/ldap/schema/inferrer'
require 'rom/ldap/lookup'
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

      schema_class Ldap::Schema
      # schema_attr_class SQL::Attribute
      # wrap_class SQL::Wrap


      # rename the image attribute used by incoming params
      # option :image, type: Symbol, reader: true, default: :jpegphoto

      # Set default dataset for a relation sub-class
      #
      # @api private
      def self.inherited(klass)
        super

        klass.class_eval do
          schema_inferrer -> (name, gateway) do
            inferrer_for_ldap = ROM::Ldap::Schema::Inferrer.new
            # begin
              inferrer_for_ldap.call(name, gateway)
            # rescue Sequel::Error => e
            #   inferrer_for_ldap.on_error(klass, e)
            #   ROM::Schema::DEFAULT_INFERRER.()
            # end

          end

          dataset do
             # TODO: feels strange to do it here - we need a new hook for this during finalization

            # binding.pry

            # klass.define_default_views!
            schema = klass.schema

            # table = opts[:from].first

            # if table
            #   if schema
            #     select(*schema.map(&:to_sql_name)).order(*schema.project(*schema.primary_key_names).qualified.map(&:to_sql_name))
            #   else
            #     select(*columns).order(*klass.primary_key_columns(db, table))
            #   end
            # else
            #   self
            # end

            self
          end


        end
      end

      # @api private
      def self.associations
        schema.associations
      end



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

      # @api private
      # def attributes
      #   # [:dn, :uid, :givenname, :sn, :cn, :mail, :objectclass]
      # end


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
