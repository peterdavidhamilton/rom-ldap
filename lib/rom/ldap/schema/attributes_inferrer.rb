require 'rom/initializer'

module ROM
  module LDAP
    class Schema < ROM::Schema
      # @api private
      class AttributesInferrer

        extend Initializer

        option :attr_class, optional: true

        # @api private
        def call(schema, gateway)
          dataset = schema.name.dataset
          columns = filter_columns(gateway, dataset)

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

        def filter_columns(gateway, dataset)
          gateway[dataset].map(&:attribute_names).flatten.uniq
        end

        def default_type
          Types::Attribute
        end

      end
    end
  end
end
