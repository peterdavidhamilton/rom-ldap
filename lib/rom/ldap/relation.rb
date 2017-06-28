require 'rom/ldap/types'
require 'rom/ldap/schema'
require 'rom/ldap/schema/inferrer'
require 'rom/ldap/attribute'
require 'rom/ldap/relation/reading'
require 'rom/ldap/relation/writing'

module ROM
  module Ldap
    class Relation < ROM::Relation
      adapter :ldap
      # gateway :default

      # auto_map true
      # auto_struct false
      # struct_namespace ROM::Struct

      include Reading
      include Writing

      schema_class      Ldap::Schema
      schema_attr_class Ldap::Attribute
      schema_inferrer   Ldap::Schema::Inferrer.new.freeze
      # wrap_class      SQL::Wrap

      # methods the relation responds to which are sent to the dataset
      #
      forward *Ldap::Dataset::Composers::Filter.query_methods

      # fetch and by_pk are prerequisites for using changesets
      # FIXME: use dn or uidnumber for pk?
      #
      # def fetch(dn)
      #   where(dn: dn)
      # end

      # alias by_pk fetch

      def primary_key
        attribute = schema.find(&:primary_key?)

        if attribute
          attribute.alias || attribute.name
        else
          :id
        end
      end

      # NB: watch for clashes with dataset methods
      #
      # def project(*names)
      #   with(schema: schema.project(*names.flatten))
      # end

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
