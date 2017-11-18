require 'rom/struct'

module ROM
  module LDAP
    class Struct < ROM::Struct
      constructor_type(:schema)
      # TODO: include Person module if objectclasses include 'person' or 'inetorgperson' ?
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

      # Remove unused attributes when converting to Hash
      #
      # @return [Hash]
      #
      def to_h
        super.delete_if { |_k, v| v.nil? }
      end

      private

      # Convenience method to alias attributes to instance methods.
      #
      def shortcut(*attributes)
        attributes.map { |m| return public_send(m) if respond_to?(m) }
      end
    end
  end
end
