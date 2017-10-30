require 'rom/struct'

module ROM
  module LDAP
    class Struct < ROM::Struct
      constructor_type(:schema)

      def self.fix_entity(schema)
        if schema.keys.any? { |k| k.to_s.include?('-') }
          Functions[:fix_entity][schema]
        else
          schema
        end
      end

      def self.attributes(schema)
        super(fix_entity(schema))
      end

      def self.new(schema)
        super(fix_entity(schema))
      end


      # TODO: include Person module if objectclasses include 'person' or 'inetorgperson'

      module Person
        def user_name
          shortcut(:uid, :cn)
        end

        def first_name
          shortcut(:gn, :givenname)
        end

        def last_name
          shortcut(:sn)
        end

        def display_name
          shortcut(:displayname, :cn)
        end

        def id
          shortcut(:uidnumber)
        end
      end

      private

      def shortcut(*attributes)
        attributes.map { |m| return public_send(m) if respond_to?(m) }
      end
    end
  end
end
