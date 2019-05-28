require 'dry/core/cache'
require 'rom/attribute'
require 'rom/ldap/attribute_dsl'

module ROM
  module LDAP
    # Extended schema attributes tailored for LDAP directories
    #
    # @api public
    class Attribute < ROM::Attribute
      extend Dry::Core::Cache

      include AttributeDSL

      # @param args [Mixed]
      # @return [ROM::LDAP::Attribute]
      #
      # @api private
      def self.[](*args)
        fetch_or_store(args) { new(*args) }
      end

      # Attribute definition identifies this is not a directory internal attribute
      # and values can be altered.
      #
      # @return [TrueClass, FalseClass]
      #
      # @api public
      def editable?
        meta[:editable].eql?(true)
      end

      # Attribute definition identifies this attribute can not have multiple values.
      #
      # @return [TrueClass, FalseClass]
      #
      # @api public
      def single?
        meta[:single].equal?(true)
      end

      # OID permits multiple values?
      #
      # @return [TrueClass, FalseClass]
      #
      # @api public
      def multiple?
        meta[:single].equal?(false)
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
      # @return [TrueClass, FalseClass]
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
      # @return [TrueClass, FalseClass]
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

      # Attribute Numeric Object Identifier
      #
      # @return [String]
      #
      # @api public
      def oid
        meta[:oid]
      end

      # Raw LDAP Attribute Definition.
      #
      # @return [String]
      #
      # @api public
      def to_definition
        meta[:definition]
      end


      # Attribute's syntax Numeric Object Identifier
      #
      # @return [String]
      #
      # @api public
      def syntax
        meta[:syntax]
      end

      # OID description
      #
      # @return [String]
      #
      # @api public
      def description
        meta[:description]
      end

      # Convert to string for ldap query using original name
      # The canonical attribute name defined in RFC4512.
      #
      # @return [String]
      #
      # @api public
      def to_s
        meta[:canonical]
      end
      alias original_name to_s


      # @api public
      def indexed?
        meta[:index].equal?(true)
      end

      # Returns a new attribute marked as indexed
      #
      # @api public
      def indexed
        meta(index: true)
      end

      # Return a new attribute in its canonical form
      #
      # @return [LDAP::Attribute]
      #
      # @api public
      def canonical
        if aliased?
          meta(alias: nil)
        else
          self
        end
      end

      # @todo Relevance to LDAP environment?
      #
      # @see Schema#qualified
      #
      # @return [LDAP::Attribute]
      #
      # @api public
      def qualified(table_alias = nil)
        return self if qualified? && table_alias.nil?

        meta(qualified: table_alias || true)
      end

      memoize :joined, :canonical, :to_s
    end
  end
end
