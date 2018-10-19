require 'rom/support/notifications'

module ROM
  module Plugins
    module Relation
      module LDAP
        # Generates methods for restricting relations by their indexed attributes
        #
        # @example
        #   rom = ROM.container(:ldap, {}) do |config|
        #
        #     config.plugin(:ldap, relations: :auto_restrictions)
        #
        #     config.relation('(cn=*)', as: :users) do
        #       schema(infer: true) do
        #         attribute :cn, Types::Strings.meta(index: true)
        #       end
        #     end
        #   end
        #
        #   rom.relations[:users].by_cn('Directory Administrator')
        #
        # @api public
        module AutoRestrictions
          extend Notifications::Listener

          subscribe('configuration.relations.schema.set', adapter: :ldap) do |event|
            schema   = event[:schema]
            relation = event[:relation]

            methods, mod = AutoRestrictions.restriction_methods(schema)
            relation.include(mod)

            methods.each { |meth| relation.auto_curry(meth) }
          end

          # @api private
          def self.restriction_methods(schema)
            mod = Module.new
            methods = schema.attributes.each_with_object([]) do |attribute, generated|
              next unless attribute.indexed?

              meth_name = :"by_#{attribute.name}"
              next if generated.include?(meth_name)

              mod.module_eval do
                define_method(meth_name) do |value|
                  where(attribute.name => value)
                end
              end

              generated << meth_name
            end

            [methods, mod]
          end
        end
      end
    end
  end
end

ROM.plugins do
  adapter :ldap do
    register :auto_restrictions, ROM::Plugins::Relation::LDAP::AutoRestrictions, type: :relation
  end
end
