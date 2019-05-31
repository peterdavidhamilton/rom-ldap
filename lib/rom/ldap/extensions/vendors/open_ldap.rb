module ROM
  module LDAP
    #
    # OpenLDAP Extension
    #
    module OpenLDAP
      #
      # @return [String]
      #
      def vendor_name
        'OpenLDAP'
      end

      #
      # @return [String]
      #
      def vendor_version
        '0.0'
      end

      #
      # @return [String]
      #
      def organization
        query(base: contexts[0]).first.first('o')
      end

    end

    Directory.send(:include, OpenLDAP)
  end
end
