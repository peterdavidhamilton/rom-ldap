require 'rom/initializer'
require 'rom/ldap/types'
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
          dataset  = schema.name.dataset
          columns  = dataset_attributes(gateway, dataset)

          inferred = columns.map do |name|

            attribute = definition(gateway, name)
            meta = Hash[name: name, source: schema.name]
            type = Types::Entry

            if attribute
              meta.merge!(description: attribute[:description]) if attribute[:description]
              meta.merge!(oid: attribute[:oid], multiple: !attribute[:single])
            end

            attr_class.new(type.meta(meta))
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
          fetch_or_store(gateway, 'types') { gateway.attribute_types }
        end

        # @return [Hash]
        #
        # @api private
        def definition(gateway, name)
          directory_attributes(gateway).select { |a| a[:name].eql?(name) }.first
        end

      end
    end
  end
end
