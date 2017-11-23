require 'rom/initializer'
require 'rom/ldap/schema/type_builder'

module ROM
  module LDAP
    class Schema < ROM::Schema
      # @api private
      class AttributesInferrer
        extend Initializer

        option :attr_class, optional: true

        # @api private
        def call(schema, gateway)
          type_builder = TypeBuilder.new(gateway.attribute_types)
          dataset      = schema.name.dataset
          columns      = dataset_attributes(gateway, dataset)

          inferred = columns.map do |name|
            type = type_builder.call(name, schema.name)
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

        # Canonical attribute names used within dataset. Array contents are effect
        # by the formatting proc.
        #
        # @return [Array<Symbol, String>]
        #
        # @example => [:cn, :dn, :given_name, :mail, :object_class, :sn]
        #
        # @api private
        def dataset_attributes(gateway, dataset)
          gateway[dataset].flat_map(&:attribute_names).uniq.sort
        end
      end
    end
  end
end
