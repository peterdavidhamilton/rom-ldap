require 'rom/ldap/types'
require 'rom/ldap/schema'
require 'rom/ldap/schema/inferrer'

module ROM
  module Ldap
    class Schema < ROM::Schema
      class DSL < ROM::Schema::DSL
        def call
          binding.pry
          Ldap::Schema.define(
            relation,

            { inferrer: inferrer }.merge(
              attributes: attributes.values,
              type_class: Ldap::Types
            )
          )
        end
      end
    end
  end
end
