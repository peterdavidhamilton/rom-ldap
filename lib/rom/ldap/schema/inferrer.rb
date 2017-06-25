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
        # ruby_type_mapping(
        #   default:                Types::StringArray,

        #   "apple-company":        Types::StringArray,
        #   "apple-generateduid":   Types::StringArray,
        #   "apple-imhandle":       Types::StringArray,
        #   "apple-mcxflags":       Types::StringArray,
        #   "apple-mcxsettings":    Types::StringArray,
        #   "apple-user-homequota": Types::StringArray,
        #   "apple-user-homeurl":   Types::StringArray,
        #   altsecurityidentities:  Types::StringArray,
        #   authauthority:          Types::StringArray,
        #   c:                      Types::StringArray,
        #   cn:                     Types::StringArray,
        #   description:            Types::StringArray,
        #   dn:                     Types::StringArray,
        #   gidnumber:              Types::StringArray,
        #   givenname:              Types::StringArray,
        #   homedirectory:          Types::StringArray,
        #   jpegphoto:              Types::Image,
        #   l:                      Types::StringArray,
        #   labeleduri:             Types::StringArray,
        #   loginshell:             Types::StringArray,
        #   mail:                   Types::StringArray,
        #   mobile:                 Types::StringArray,
        #   objectclass:            Types::StringArray,
        #   postalcode:             Types::StringArray,
        #   shadowexpire:           Types::StringArray,
        #   shadowlastchange:       Types::StringArray,
        #   sn:                     Types::StringArray,
        #   st:                     Types::StringArray,
        #   street:                 Types::StringArray,
        #   uid:                    Types::StringArray,
        #   uidnumber:              Types::StringArray,
        #   userpassword:           Types::StringArray
        # ).freeze

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

        # # @api private
        def call(source, gateway)
          # objectclasses  ||= schema_entries(gateway, :objectclasses)
          # attributetypes ||= schema_entries(gateway, :attributetypes)
          # all_attributes ||= parse_entries(attributetypes)
          attributes = used_attributes(gateway, source.dataset)

          inferred = attributes.map do |name|
            # NB: inference disabled if coercion is handled outside this adapter and all incoming datasets are arrays of strings.
            # type = map_type(name)
            Types::Attribute.meta(name: name, source: source)
          end

          [inferred, attributes - inferred.map { |attr| attr.meta[:name] }]
        end

        private

        # def map_type(name)
        #   mappings = self.class.ruby_type_mapping
        #   mappings[name] || mappings[:default]
        # end

        def used_attributes(gateway, filter)
          begin
            gateway.connection.bind
          rescue ::Net::LDAP::ConnectionRefusedError,
                 ::Errno::ECONNREFUSED,
                 ::Net::LDAP::Error => error
            on_error(filter, error)
          else
            gateway.connection.search(filter: filter)
            .map(&:attribute_names).flatten.uniq
          end
        end

        # Abort if a relation schema uses inference.
        # Unlike the dataset which will rescue with an empty array
        def on_error(relation, e)
          abort "ROM::Ldap::Relation[#{relation}] failed to infer schema. (#{e.message})"
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
