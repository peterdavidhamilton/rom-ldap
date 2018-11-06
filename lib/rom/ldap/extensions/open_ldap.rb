#
# Directory.include OpenLDAP
#
module ROM
  module LDAP
    module OpenLDAP
      def vendor_name
        'OpenLDAP'
      end

      def vendor_version
        '0.0'
      end

      def organization
        query(filter: '(objectClass=organization)').first['o'][0]
      end
    end

    Directory.send(:include, OpenLDAP)
  end
end
