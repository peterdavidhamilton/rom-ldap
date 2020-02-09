# frozen_string_literal: true

module ROM
  module LDAP
    # @api private
    module Unknown
      # @return [String]
      #
      # @api public
      def vendor_name
        'Unknown'
      end

      # @return [String]
      #
      # @api public
      def vendor_version
        'Unknown'
      end
    end
  end
end
