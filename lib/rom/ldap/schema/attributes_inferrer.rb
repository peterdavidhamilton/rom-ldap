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
          gateway[dataset].map(&:attribute_names).flatten.uniq
        end

        # all attribute types used by any entry
        def used_columns(gateway)
          gateway[nil].map(&:attribute_names).flatten.uniq
        end

        # all possible attribute types
        def known_columns(gateway)
          gateway.attribute_types.map { |a| a.scan(/NAME '(\S+)'/) }.flatten.uniq.sort.map(&:to_sym)
        end

        def default_type
          Types::Entry
        end

      end
    end
  end
end
