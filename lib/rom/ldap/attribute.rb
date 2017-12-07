require 'dry/core/cache'
require 'rom/attribute'

module ROM
  module LDAP
    # Extended schema attributes tailored for LDAP directories
    #
    # @api public
    class Attribute < ROM::Attribute
      extend Dry::Core::Cache

      # @api private
      def self.[](*args)
        fetch_or_store(args) { new(*args) }
      end

      # Return a new attribute with an alias
      #
      # @example
      #   users[:id].aliased(:user_id)
      #
      # @return [LDAP::Attribute]
      #
      # @api public
      def aliased(name)
        super.meta(name: meta.fetch(:name, name))
      end
      alias_method :as, :aliased


      # Return a new attribute in its canonical form
      #
      # @api public
      def canonical
        if aliased?
          meta(alias: nil)
        else
          self
        end
      end


      # Return a new attribute marked as joined
      #
      # Whenever you join two schemas, the right schema's attribute
      # will be marked as joined using this method
      #
      # @return [LDAP::Attribute] Original attribute marked as joined
      #
      # @api public
      def joined
        meta(joined: true)
      end

      # Return if an attribute was used in a join
      #
      # @example
      #   schema = users.schema.join(tasks.schema)
      #
      #   schema[:id, :tasks].joined?
      #   # => true
      #
      # @return [Boolean]
      #
      # @api public
      def joined?
        meta[:joined].equal?(true)
      end

      # Return if an attribute type is qualified
      #
      # @example
      #   id = users[:id].qualify
      #
      #   id.qualified?
      #   # => true
      #
      # @return [Boolean]
      #
      # @api public
      def qualified?
        meta[:qualified].equal?(true) || meta[:qualified].is_a?(Symbol)
      end

      # Return a new attribute marked as a FK
      #
      # @return [LDAP::Attribute]
      #
      # @api public
      def foreign_key
        meta(foreign_key: true)
      end

      # LDAP Attribute Object Identifier
      #
      # @return [BER::BerIdentifiedString]
      #
      # @api public
      def oid
        meta[:oid]
      end

      # OID expects multiple values?
      #
      # @return [Boolean]
      #
      # @api public
      def multiple?
        meta[:multiple]
      end

      # OID description
      #
      # @return [BER::BerIdentifiedString]
      #
      # @api public
      def description
        meta[:description]
      end

      # The attribute name as it appears in the server's schema.
      #
      # @return [String]
      #
      # @api public
      def original_name
        meta[:original]
      end


      # Convert to string for ldap query using original name
      #
      # @return [String]
      #
      # @api public
      def to_s
        original_name || Directory.attributes.detect { |a| a[:name] == name }[:original]
      end

      # Return a new attribute in its canonical form
      #
      # @api public
      def canonical
        if aliased?
          meta(alias: nil)
        else
          self
        end
      end

      # @see Schema#qualified
      #
      # @return [LDAP::Attribute]
      #
      # @api public
      def qualified(table_alias = nil)
        return self if qualified? && table_alias.nil?
        type = meta(qualified: table_alias || true)
      end

      private

      memoize :joined, :canonical, :to_s
    end
  end
end
