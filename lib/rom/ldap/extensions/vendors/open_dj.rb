module ROM
  module LDAP
    #
    # OpenDJ Server Extension
    #
    module OpenDJ

      # @return [String]
      #
      # @api public
      def vendor_name
        root.first('vendorName')
      end

      # @return [String]
      #
      # @api public
      def vendor_version
        root.first('vendorVersion')
      end

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

    Directory.send(:include, OpenDJ)
  end
end
