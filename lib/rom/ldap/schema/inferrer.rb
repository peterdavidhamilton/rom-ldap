require 'rom/ldap/schema/attributes_inferrer'
require 'rom/ldap/attribute'

module ROM
  module LDAP
    class Schema < ROM::Schema
      # @api private
      class Inferrer < ROM::Schema::Inferrer

        attributes_inferrer -> (schema, gateway, options) do
          # TODO: differentiate between different directory backends
          # AttributesInferrer.get(gateway.database_type).with(options).(schema, gateway)

          AttributesInferrer.new(options).(schema, gateway)
        end

        attr_class LDAP::Attribute

        option :silent, default: -> { false }

        option :raise_on_error, default: -> { true }

        FALLBACK_SCHEMA = { attributes: EMPTY_ARRAY, indexes: EMPTY_SET }.freeze

        # @api private
        def call(schema, gateway)
          inferred = super

          # indexes = get_indexes(gateway, schema.name.dataset, inferred[:attributes])
          # { **inferred, indexes: indexes }

          { **inferred }

        rescue ::Net::LDAP::ConnectionRefusedError,
               ::Errno::ECONNREFUSED,
               ::Net::LDAP::Error => e

          on_error(schema.name, e)
          FALLBACK_SCHEMA
        end

        def suppress_errors
          with(raise_on_error: false, silent: true)
        end

        def on_error(relation, e = nil)
          abort "ROM::LDAP::Relation[#{relation}] failed to infer schema. #{e.message}"
        end
      end
    end
  end
end
