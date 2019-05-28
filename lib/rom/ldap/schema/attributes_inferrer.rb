require 'rom/initializer'

module ROM
  module LDAP
    class Schema < ROM::Schema
      # @api private
      class AttributesInferrer
        extend Initializer

        option :type_builder
        option :attr_class, optional: true

        # @api private
        def call(schema, gateway)
          dataset = schema.name.dataset
          columns = dataset_attributes(gateway, dataset)

          inferred = columns.map do |name|
            type = type_builder.call(name, schema.name)
            attr_class.new(type, name: name.to_sym)
          end

          missing = columns - inferred.map { |attr| attr.meta[:name] }

          [inferred, missing]
        end

        # @api private
        def with(new_options)
          self.class.new(options.merge(new_options))
        end

        private


        # All possible formatted Entry attribute names.
        #
        # @see Directory#query_attributes
        #
        # @param dataset [String] LDAP filter string / dataset name
        # @param gateway [ROM::LDAP::Gateway]
        #
        # @return [Array<Symbol, String>]
        #
        # @example => [:cn, :dn, :given_name, :mail, :object_class, :sn]
        #
        # @api private
        def dataset_attributes(gateway, dataset)
          gateway[dataset].flat_map(&:keys).uniq.sort
        end
      end
    end
  end
end
