require 'rom/initializer'
require 'dry/core/cache'
require 'rom/ldap/schema/type_builder'

module ROM
  module LDAP
    class Schema < ROM::Schema
      # @api private
      class AttributesInferrer

        extend Initializer
        extend Dry::Core::Cache

        option :attr_class, optional: true

        # @api private
        def call(schema, gateway)
          attributes    = directory_attributes(gateway)
          type_builder  = TypeBuilder.new(attributes)
          dataset       = schema.name.dataset
          columns       = dataset_attributes(gateway, dataset)

          inferred = columns.map do |name|
            type = type_builder.(name, schema.name)
            attr_class.new(type)
          end

          missing = columns - inferred.map { |attr| attr.meta[:name] }

          [inferred, missing]
        end

        # @api private
        def with(new_options)
          self.class.new(options.merge(new_options))
        end

        private

        # Attributes used by filtered entries
        #
        # @example
        #   dataset_attributes(ROM::LDAP::Gateway, "(cn=*)")
        #     # =>  [:cn, :dn, :givenname, :mail, :objectclass, :sn]
        #
        # @return [Array<Symbol>]
        #
        # @api private
        def dataset_attributes(gateway, dataset)
          fetch_or_store(gateway, dataset) do
            gateway[dataset].flat_map(&:attribute_names).uniq.sort
          end
        end

        def directory_attributes(gateway)
          fetch_or_store(gateway, 'types') do
            gateway.attribute_types
          end
        end
      end
    end
  end
end
