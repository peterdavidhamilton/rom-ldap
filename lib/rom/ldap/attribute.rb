require 'rom/attribute'

module ROM
  module LDAP
    # Extended schema attributes tailored for LDAP directories
    #
    # @api public
    class Attribute < ROM::Attribute
      # @return [Boolean]
      def multiple?
        meta[:multiple]
      end

      # @return [BER::BerIdentifiedString]
      def description
        meta[:description]
      end

      # @return [BER::BerIdentifiedString]
      def oid
        meta[:oid]
      end

      # The attrbiute name as it appears in the server's schema.
      #
      # @return [String]
      def original_name
        meta[:original]
      end

      #
      # @return [LDAP::Attribute]
      #
      # @api public
      def qualified(table_alias = nil)
        # binding.pry
      end
    end
  end
end
