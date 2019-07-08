module ROM
  module LDAP
    #
    # Novell eDirectory Extension
    #
    module EDirectory

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



      # def transactions
      # end
    end

    Directory.include EDirectory
  end
end
