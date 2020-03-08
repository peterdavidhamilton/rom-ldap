# frozen_string_literal: true

require 'rom/ldap/schema/type_builder'
require 'rom/ldap/schema/attributes_inferrer'
require 'rom/ldap/attribute'

module ROM
  module LDAP
    class Schema < ROM::Schema

      # @api private
      class Inferrer < ROM::Schema::Inferrer

        attributes_inferrer ->(schema, gateway, options) do
          builder  = TypeBuilder.new(gateway.attribute_types)
          inferrer = AttributesInferrer.new(type_builder: builder, **options)
          inferrer.call(schema, gateway)
        end

        attr_class LDAP::Attribute

        option :silent, default: -> { false }

        option :raise_on_error, default: -> { true }

        FALLBACK_SCHEMA = {
          attributes: EMPTY_ARRAY,
          indexes:    EMPTY_SET
        }.freeze

        # @api private
        def call(schema, gateway)
          inferred = super

          { **inferred }
        rescue *CONNECTION_FAILURES => e
          raise ConnectionError, e
        ensure
          FALLBACK_SCHEMA
        end

        def suppress_errors
          with(raise_on_error: false, silent: true)
        end

      end

    end
  end
end
