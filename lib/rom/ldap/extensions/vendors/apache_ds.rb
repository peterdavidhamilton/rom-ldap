module ROM
  module LDAP
    #
    # Apache Directory Extension
    #
    module ApacheDS
      IGNORE_ATTRS_REGEX = /^[m-|ads|entry].*$/.freeze

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

      # @return [Array]
      #
      # @api public
      def schemas
        query(base: 'ou=schema', filter: '(objectClass=metaAttributeType)')
      end

      # def schemas
      #   query(base: 'ou=schema', filter: '(objectClass=metaObjectClass)')
      # end
    end

    Directory.send(:include, ApacheDS)
  end
end
