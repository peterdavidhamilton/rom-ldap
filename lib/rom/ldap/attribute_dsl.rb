
module ROM
  module LDAP

    module AttributeDSL # < ROM::Attribute


      # Input will not be escaped!
      #
      # prebuilt equality operator ast
      #
      #
      # @param other [Mixed]
      #
      # @example
      #   users.where { id.is(1) }
      #   users.where { id == 1 }
      #
      #   users.where(users[:id].is(1))
      #
      # @return [Hash]
      #
      # @api public
      def is(other)
        [:op_eql, name, other]
      end
      alias == is

      # @example
      #   users.where { given_name.exists }
      #
      def exists
        [:op_eql, name, :wildcard]
      end

      # @example
      #   users.where { uid_number.gt(101) }
      #   users.where { uid_number > 101 }
      #
      def gt(other)
        [:con_not, [:op_lte, name, other]]
      end
      alias > gt

      # @example
      #   users.where { uid_number.lt(101) }
      #   users.where { uid_number < 101 }
      #
      def lt(other)
        [:con_not, [:op_gte, name, other]]
      end
      alias < lt


      # @example
      #   users.where { uid_number.gte(101) }
      #   users.where { uid_number >= 101 }
      #
      def gte(other)
        [:op_gte, name, other]
      end
      alias >= gte

      # @example
      #   users.where { uid_number.lte(101) }
      #   users.where { uid_number <= 101 }
      #
      def lte(other)
        [:op_lte, name, other]
      end
      alias <= lte

      # @example
      #   users.where { given_name.like('peter') }
      #   users.where { given_name =~ 'peter' }
      #
      def like(other)
        [:op_prx, name, other]
      end
      alias =~ like


      # @see https://ldapwiki.com/wiki/ExtensibleMatch
      #
      def extensible(other)
        [:op_ext, name, other]
      end

      def bitwise(other)
        [:op_eql, name, other]
      end


    end
  end
end
