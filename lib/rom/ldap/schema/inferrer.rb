require 'rom/ldap/schema/attributes_inferrer'
require 'rom/ldap/attribute'

module ROM
  module LDAP
    class Schema < ROM::Schema
      # @api private
      class Inferrer < ROM::Schema::Inferrer

        attributes_inferrer ->(schema, gateway, options) do
          AttributesInferrer.new(options).call(schema, gateway)
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

        # rescue *ERROR_MAP.keys => e
        #   raise ERROR_MAP.fetch(e.class, Error), e
        # rescue
        #   binding.pry
        #   FALLBACK_SCHEMA
        end

        def suppress_errors
          with(raise_on_error: false, silent: true)
        end
      end
    end
  end
end
