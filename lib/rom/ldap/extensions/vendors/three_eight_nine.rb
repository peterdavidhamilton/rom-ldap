module ROM
  module LDAP
    #
    # RedHat 389DS Extension
    #
    module ThreeEightNine

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

      # def netscapemdsuffix
      #   root.first('netscapemdsuffix')
      # end
    end

    Directory.send(:include, ThreeEightNine)
  end
end
