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

      # rename the image attribute used by incoming params
      # option :image, type: Symbol, reader: true, default: :jpegphoto

      # Set default dataset for a relation sub-class
      #
      # @api private
      def self.inherited(klass)
        super

        klass.class_eval do
          schema_class  Ldap::Schema
          schema_dsl    Ldap::Schema::DSL

          # schema_inferrer -> (name, gateway) do
          #   ROM::Ldap::Schema::Inferrer.new.call(name, gateway)
          # end

        end
      end


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


      # ROM::Relation::Name(entries)
      #
      # @api private
      def base_name
        name
      end


      # @api private
      def attributes
        [:dn, :uid, :givenname, :sn, :cn, :mail, :objectclass]
      end

      # called inside commands - merged into tuples
      #
      # @api private
      def default_attrs
        {
             # dn: 'uid=fallback,ou=users,dc=test',
            uid: 'fallback',
             cn: 'fallback',
      givenname: 'fallback',
             sn: 'fallback',
           # mail: '',
    objectclass: ['extensibleObject',
                  'top',
                  'organizationalPerson',
                  'inetOrgPerson',
                  'person']
        }
      end

    end
  end
end
