module ROM
  module LDAP
    #
    # Apple Open Directory Extension
    #
    module OpenDirectory

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
    end

    Directory.include OpenDirectory
  end
end
