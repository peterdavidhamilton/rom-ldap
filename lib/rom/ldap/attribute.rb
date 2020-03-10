# frozen_string_literal: true

require 'dry/core/cache'
require 'rom/attribute'

module ROM
  module LDAP
    # Extended schema attributes tailored for LDAP directories
    #
    # @api public
    class Attribute < ROM::Attribute

      extend Dry::Core::Cache

      # @param args [Mixed]
      #
      # @return [ROM::LDAP::Attribute]
      #
      # @api public
      def self.[](*args)
        fetch_or_store(args) { new(*args) }
      end

      # Attribute definition identifies this is not a directory internal attribute
      # and values can be altered.
      #
      # @return [Boolean]
      #
      # @api public
      def editable?
        meta[:editable].equal?(true)
      end

      # Attribute definition identifies this attribute can not have multiple values.
      #
      # @return [Boolean]
      #
      # @api public
      def single?
        meta[:single].equal?(true)
      end

      # OID permits multiple values?
      #
      # @return [Boolean]
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
      # @return [Boolean]
      #
      # @api public
      def joined?
        meta[:joined].equal?(true)
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
      def definition
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
        meta[:canonical] || name.to_s
      end
      alias_method :original_name, :to_s

      # @return [Boolean]
      #
      # @api public
      def indexed?
        meta[:index].equal?(true)
      end

      # Returns a new attribute marked as indexed
      #
      # @return [LDAP::Attribute]
      #
      # @api public
      def indexed
        meta(index: true)
      end

      # Return a new attribute in its canonical form
      #
      # @see Dataset#export
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

      # @example
      #   users.where { given_name.exists }
      #   users.where { ~given_name }
      #
      # @return [Array]
      #
      # @api public
      def exists
        [:op_eql, name, :wildcard]
      end
      alias_method :~@, :exists

      # @example
      #   users.where { !given_name }
      #
      # @return [Array]
      #
      # @api public
      def !@
        [:con_not, exists]
      end

      # @param value [Mixed]
      #
      # @example
      #   users.where { id.is(1) }
      #   users.where { id == 1 }
      #
      #   users.where(users[:id].is(1))
      #
      # @return [Array]
      #
      # @api public
      def is(value)
        [:op_eql, name, value]
      end
      alias_method :==, :is

      # @param value [Mixed]
      #
      # @example
      #   users.where { id.not(1) }
      #   users.where { id != 1 }
      #
      # @return [Array]
      #
      # @api public
      def not(value)
        [:con_not, is(value)]
      end
      alias_method :!=, :not

      # @param value [Mixed]
      #
      # @example
      #   users.where { uid_number.gt(101) }
      #   users.where { uid_number > 101 }
      #
      # @return [Array]
      #
      # @api public
      def gt(value)
        [:con_not, lte(value)]
      end
      alias_method :>, :gt

      # @param value [Mixed]
      #
      # @example
      #   users.where { uid_number.lt(101) }
      #   users.where { uid_number < 101 }
      #
      # @return [Array]
      #
      # @api public
      def lt(value)
        [:con_not, gte(value)]
      end
      alias_method :<, :lt

      # @param value [Mixed]
      #
      # @example
      #   users.where { uid_number.gte(101) }
      #   users.where { uid_number >= 101 }
      #
      # @return [Array]
      #
      # @api public
      def gte(value)
        [:op_gte, name, value]
      end
      alias_method :>=, :gte

      # @param value [Mixed]
      #
      # @example
      #   users.where { uid_number.lte(101) }
      #   users.where { uid_number <= 101 }
      #
      # @return [Array]
      #
      # @api public
      def lte(value)
        [:op_lte, name, value]
      end
      alias_method :<=, :lte

      # @param value [Mixed]
      #
      # @example
      #   users.where { given_name.like('peter') }
      #   users.where { given_name =~ 'peter' }
      #
      # @return [Array]
      #
      # @api public
      def like(value)
        [:op_prx, name, value]
      end
      alias_method :=~, :like

      # @param value [Mixed]
      #
      # @example
      #   users.where { given_name.not_like('peter') }
      #   users.where { given_name !~ 'peter' }
      #
      # @return [Array]
      #
      # @api public
      def not_like(value)
        [:con_not, like(value)]
      end
      alias_method :!~, :not_like

      # @param value [Mixed]
      #
      # @see https://ldapwiki.com/wiki/ExtensibleMatch
      #
      # @return [Array]
      #
      # @api public
      def extensible(value)
        [:op_ext, name, value]
      end

      # @param value [Mixed]
      #
      # @return [Array]
      #
      # @api public
      def bitwise(value)
        [:op_eql, name, value]
      end
      alias_method :===, :bitwise

      memoize :oid, :syntax, :joined, :canonical, :to_s

    end
  end
end
