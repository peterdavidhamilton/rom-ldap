require 'dry/core/class_attributes'

module ROM
  module Ldap
    class Schema < ROM::Schema
      # @api private
      class Inferrer
        extend Dry::Core::ClassAttributes

        defines :ruby_type_mapping,
                :directory_type,
                :directory_registry,
                :numeric_pk_type

        # known types - unknown could be derived from class lookup
        ruby_type_mapping(
          default:                Types::Attribute,

          "apple-company":        Types::Array.member(Types::String),
          "apple-generateduid":   Types::Array.member(Types::String),
          "apple-imhandle":       Types::Array.member(Types::String),
          "apple-mcxflags":       Types::Array.member(Types::String),
          "apple-mcxsettings":    Types::Array.member(Types::String),
          "apple-user-homequota": Types::Array.member(Types::String),
          "apple-user-homeurl":   Types::Array.member(Types::String),
          altsecurityidentities:  Types::Array.member(Types::String),
          authauthority:          Types::Array.member(Types::String),
          c:                      Types::Array.member(Types::String),
          cn:                     Types::Array.member(Types::String),
          description:            Types::Array.member(Types::String),
          dn:                     Types::Array.member(Types::String),
          gidnumber:              Types::Array.member(Types::Int),
          givenname:              Types::Array.member(Types::String),
          homedirectory:          Types::Array.member(Types::String),
          jpegphoto:              Types::Image,
          l:                      Types::Array.member(Types::String),
          labeleduri:             Types::Array.member(Types::String),
          loginshell:             Types::Array.member(Types::String),
          mail:                   Types::Array.member(Types::String),
          mobile:                 Types::Array.member(Types::String),
          objectclass:            Types::ObjectClasses,
          postalcode:             Types::Array.member(Types::String),
          shadowexpire:           Types::Array.member(Types::Date),
          shadowlastchange:       Types::Array.member(Types::Date),
          sn:                     Types::Array.member(Types::String),
          st:                     Types::Array.member(Types::String),
          street:                 Types::Array.member(Types::String),
          uid:                    Types::Array.member(Types::String),
          uidnumber:              Types::Array.member(Types::Int),
          userpassword:           Types::Array.member(Types::String)
        ).freeze

        directory_registry Hash.new(self)

        numeric_pk_type Types::Int
        # numeric_pk_type Types::Serial

        def self.get(type)
          directory_registry[type]
        end

        def self.inherited(klass)
          super

          Inferrer.db_registry[klass.directory_type] = klass unless klass.name.nil?
        end

        def self.[](type)
          Class.new(self) { directory_type(type) }
        end

        def self.on_error(relation, e)
          warn "[#{relation}] failed to infer schema. " \
               "This LDAP territory" \
               "(#{e.message})"
        end

        # # @api private
        def call(source, gateway)
          # objectclasses  ||= schema_entries(gateway, :objectclasses)
          # attributetypes ||= schema_entries(gateway, :attributetypes)
          # all_attributes ||= parse_entries(attributetypes)
          attributes = used_attributes(gateway, source.dataset)

          inferred = attributes.map do |name|
            type = map_type(name)
            type.meta(name: name, source: source)
          end

          [inferred, attributes - inferred.map { |attr| attr.meta[:name] }]
        end

        private

        def map_type(name)
          mappings = self.class.ruby_type_mapping
          mappings[name] or mappings[:default]
        end

        def used_attributes(gateway, filter)
          gateway.connection.search(filter: filter)
            .map(&:attribute_names).flatten.uniq
        end

        # def all_attributes(gateway)
        #   gateway.connection.search
        #     .map(&:attribute_names).flatten.uniq
        # end

        # def schema_entries(gateway, schema_entry)
        #   gateway.connection.search_subschema_entry[schema_entry].to_a
        # end

        # def parse_entries(entries)
        #   entries.map do |entry|
        #     entry.split(' ')[3].tr("'", '').to_sym
        #   end
        # end
      end
    end
  end
end
