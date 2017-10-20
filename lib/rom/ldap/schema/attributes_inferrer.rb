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
          columns = columns(gateway)

          # [
          #   [0] "1.2.840.113556.1.4.7000.102.51233",
          #   [1] "msExchFedMetadataPollInterval",
          #   [2] "1.3.6.1.4.1.1466.115.121.1.27",
          #   [3] "SINGLE-VALUE"
          # ],

          inferred = columns.map do |code, name, oid, type|
          # inferred = columns.map do |name|
            # attr_class.new(default_type.meta(name: name, source: schema.name))
            attr_class.new(default_type.meta(name: name.to_sym, source: schema.name))
          end

          missing = columns - inferred.map { |attr| attr.meta[:name] }

          [inferred, missing]
        end

        # @api private
        def with(new_options)
          self.class.new(options.merge(new_options))
        end

        private

        TYPE_REGEX = %r"^\( (\S+) NAME '(\S+)' SYNTAX '(\S+)' (\S+){0,} \)$"

        # all possible attribute types
        def columns(gateway)
          gateway.attribute_types.map { |a| a.scan(TYPE_REGEX) }.reject(&:empty?).map(&:flatten)
          # .flatten.uniq.sort.map(&:to_sym)
        end

        def default_type
          Types::Entry
        end

      end
    end
  end
end
