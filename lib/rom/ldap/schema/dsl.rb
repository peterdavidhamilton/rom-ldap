require 'rom/ldap/type'
require 'rom/ldap/schema'
# require 'rom/ldap/schema/inferrer'
# require 'rom/ldap/schema/associations_dsl'






module ROM
  module Ldap
    class Schema < ROM::Schema
      class DSL < ROM::Schema::DSL
        attr_reader :associations_dsl

        # def associations(&block)
        #   @associations_dsl = AssociationsDSL.new(relation, &block)
        # end

        def call
          Ldap::Schema.define(
            relation, opts.merge(attributes: attributes.values, type_class: Ldap::Type)
          )
        end

        def opts
          opts = { inferrer: inferrer }

          if associations_dsl
            { **opts, associations: associations_dsl.call }
          else
            opts
          end
        end
      end
    end
  end
end
