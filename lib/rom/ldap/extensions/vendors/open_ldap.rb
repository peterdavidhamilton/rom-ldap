module ROM
  module LDAP
    #
    # OpenLDAP
    #
    module OpenLDAP
      #
      # @return [String]
      #
      def vendor_name
        'OpenLDAP'.freeze
      end

      #
      # @return [String]
      #
      def vendor_version
        '0.0'.freeze
      end

      #
      # @return [String]
      #
      def organization
        query(filter: '(objectClass=organization)').first['o'][0]
      end
    end

    Directory.send(:include, OpenLDAP)
  end
end
