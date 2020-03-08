# frozen_string_literal: true

module ROM
  module LDAP
    #
    # OpenDJ Server Extension
    #
    # @api private
    module OpenDj
      # @return [String]
      #
      # @api public
      def full_vendor_version
        root.first('fullVendorVersion')
      end

      # @return [String]
      #
      # @api public
      def etag
        root.first('etag')
      end
    end
  end
end
