module ROM
  module Ldap
    class Schema < ROM::Schema
      # @api private
      class AttributesInferrer

        extend Initializer

        option :attr_class, optional: true

        # @api private
        # def with(new_options)
        #   self.class.new(options.merge(new_options))
        # end

        # @api private
        def call(schema, gateway)
          dataset = schema.name.dataset
          columns = filter_columns(gateway.connection, dataset)

          inferred = columns.map do |name|
            attr_class.new(Types::Attribute.meta(name: name, source: schema.name))
          end

          missing = columns - inferred.map { |attr| attr.meta[:name] }

          [inferred, missing]
        end


        private

        def filter_columns(connection, dataset)
          begin
            connection.bind
          rescue ::Net::LDAP::ConnectionRefusedError,
                 ::Errno::ECONNREFUSED,
                 ::Net::LDAP::Error => error

            on_error(dataset, error)
          else
            raw_data = connection.search(filter: dataset)
            attrs    = raw_data.map(&:attribute_names).flatten.uniq
            attrs.blank? ? on_error(dataset) : attrs
          end
        end

      end
    end
  end
end
