require 'dry/core/class_attributes'

module ROM
  module Ldap
    class Schema < ROM::Schema

      # @api private
      class Inferrer
        extend Dry::Core::ClassAttributes

        defines :ruby_type_mapping #, :numeric_pk_type, :db_type, :db_registry

        ruby_type_mapping(
          ou:           Types::Attribute,
          dn:           Types::Attribute,
          uid:          Types::Attribute,
          givenname:    Types::Attribute,
          sn:           Types::Attribute,
          cn:           Types::Attribute,
          mail:         Types::Attributes,
          userpassword: Types::Attribute,
          jpegphoto:    Types::Image,
          objectclass:  Types::Attributes,
        ).freeze


        # # @api private
        # def call(source, gateway)

        #   # gateway.connection.search_subschema_entry[:attributetypes].to_a
        #   # gateway.connection.search_subschema_entry[:objectclasses].to_a

        #   attributes = gateway.connection.search.map(&:attribute_names).flatten.uniq

        #   inferred = attributes.each_with_object({}) do |name, attrs|
        #     # binding.pry
        #     # type = map_type(name)
        #     # attrs[name] = type.meta(name: name, source: source)

        #     attrs[name] = map_type(name)
        #   end

        #   # [inferred, attributes.map(&:first) - inferred.map { |attr| attr.meta[:name] }]

        #   # NoMethodError: undefined method `meta' for :dn:Symbol
        #   # /Users/hamilt09/Code/rom-ldap/lib/rom/ldap/schema.rb:25:in `finalize!'
        #   inferred.to_a
        # end


        def map_type(ruby_type)
          self.class.ruby_type_mapping.fetch(ruby_type)
        end

      end
    end
  end
end
