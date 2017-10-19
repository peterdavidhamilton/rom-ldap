require 'rom/initializer'
require 'dry/core/cache'

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
          dataset = schema.name.dataset
          columns = dataset_columns(gateway, dataset)
          columns = known_columns(gateway) if columns.size.zero?

          inferred = columns.map do |name|
            attr_class.new(default_type.meta(name: name, source: schema.name))
          end

          missing = columns - inferred.map { |attr| attr.meta[:name] }

          [inferred, missing]
        end

        # @api private
        def with(new_options)
          self.class.new(options.merge(new_options))
        end

        private

        # attributes used by filtered entries
        def dataset_columns(gateway, dataset)
          fetch_or_store(gateway, dataset) do
            gateway[dataset].map(&:attribute_names).flatten.uniq.sort
          end
        end

        # all attribute types used by any entry
        def used_columns(gateway)
          fetch_or_store(gateway, nil) do
            gateway[nil].map(&:attribute_names).flatten.uniq.sort
          end
        end

        # all possible attribute types
        def known_columns(gateway)
          fetch_or_store(gateway) do
            gateway.attribute_types.map { |a| a.scan(/NAME '(\S+)'/) }.flatten.uniq.sort.map(&:to_sym)
          end
        end

        def default_type
          Types::Entry
        end

      end
    end
  end
end
