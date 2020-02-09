# frozen_string_literal: true

module ROM
  module LDAP
    #
    # OpenLDAP Extension
    #
    # @api private
    module OpenLdap
      #
      # @return [String]
      #
      # @api public
      def vendor_name
        'OpenLDAP'
      end

      #
      # @return [String]
      #
      # @api public
      def vendor_version
        '0.0'
      end

      #
      # @return [String]
      #
      # @api public
      def organization
        query(base: contexts[0]).first.first('o')
      end
    end
  end
end
