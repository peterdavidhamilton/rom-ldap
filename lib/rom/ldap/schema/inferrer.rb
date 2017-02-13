require 'dry/core/class_attributes'

module ROM
  module Ldap
    class Schema < ROM::Schema
      # @api private
      class Inferrer
        extend Dry::Core::ClassAttributes

        defines :ruby_type_mapping, :db_type, :db_registry # , :numeric_pk_type

        ruby_type_mapping(
          ou:           Types::Attribute,
          dn:           Types::Attribute,
          uid:          Types::Attribute,
          givenname:    Types::Attribute,
          sn:           Types::Attribute,
          cn:           Types::Attribute,
          mail:         Types::Attribute,
          userpassword: Types::Attribute,
          jpegphoto:    Types::Image,
          objectclass:  Types::ObjectClasses
        ).freeze

        db_registry Hash.new(self)

        def self.get(type)
          db_registry[type]
        end

        def self.[](type)
          Class.new(self) { db_type(type) }
        end

        # # @api private
        def call(source, gateway)
          # [
          #   [0] :dn,
          #   [1] :sn,
          #   [2] :cn,
          #   [3] :objectclass,
          #   [4] :givenname,
          #   [5] :uid,
          #   [6] :mail,
          #   [7] :jpegphoto,
          #   [8] :userpassword,
          #   [9] :ou
          # ]
          attributes = gateway.connection.search.map(&:attribute_names).flatten.uniq

          # gateway.connection.search_subschema_entry[:attributetypes].to_a
          # gateway.connection.search_subschema_entry[:objectclasses].to_a

          inferred = attributes.each_with_object({}) do |name, attrs|
            type = map_type(name)
            attrs[name] = type.meta(name: name, source: source)
          end

          # [inferred, attributes.map(&:first) - inferred.map { |attr| attr.meta[:name] }]

          [*inferred, attributes]

          # inferred.to_a
        end

        # def build_type(primary_key:, db_type:, type:, allow_null:, foreign_key:, **rest)
        #    if primary_key
        #      map_pk_type(type, db_type)
        #    else
        #      mapped_type = map_type(type, db_type, rest)

        #      if mapped_type
        #        read_type = mapped_type.meta[:read]
        #        mapped_type = mapped_type.optional if allow_null
        #        mapped_type = mapped_type.meta(foreign_key: true, target: foreign_key) if foreign_key
        #        if read_type && allow_null
        #          mapped_type.meta(read: read_type.optional)
        #        elsif read_type
        #          mapped_type.meta(read: read_type)
        #        else
        #          mapped_type
        #        end
        #      end
        #    end
        #  end

        def map_type(ruby_type)
          self.class.ruby_type_mapping.fetch(ruby_type)
        end
      end
    end
  end
end
