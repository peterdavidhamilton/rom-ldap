module ROM
  module LDAP
    class Directory
      module Root

        # Identifiy the vendor of the LDAP server.
        #
        # @see https://ldapwiki.com/wiki/Determine%20LDAP%20Server%20Vendor
        #
        # @return [Symbol] 1 of 11
        #
        #     :active_directory
        #     :apache_ds
        #     :e_directory
        #     :ibm
        #     :netscape
        #     :open_directory
        #     :open_ldap
        #     :oracle
        #     :sun_microsystems
        #     :three_eight_nine
        #     :unknown
        #
        # @api public
        def type
          case root.first('vendorName')
          when /389/      then :three_eight_nine
          when /Apache/   then :apache_ds
          when /Apple/    then :open_directory
          when /IBM/      then :ibm
          when /Netscape/ then :netscape
          when /Novell/   then :e_directory
          when /Oracle/   then :oracle
          when /Sun/      then :sun_microsystems
          when nil
            :active_directory if ad?
            :open_ldap if od?
          else
            :unknown
          end
        end

        # Check if vendor identifies as ActiveDirectory
        #
        # @return [Boolean]
        #
        # @api public
        def ad?
          !!root['forestFunctionality']
        end

        # Check if vendor identifies as OpenLDAP
        #
        # @return [Boolean]
        #
        # @api public
        def od?
          root['objectClass']&.include?('OpenLDAProotDSE')
        end


        # @return [Array<String>]
        #
        # @example
        #   [ 'Apple', '510.30' ]
        #   [ 'Apache Software Foundation', '2.0.0-M24' ]
        #
        # @api public
        def vendor
          [vendor_name, vendor_version]
        end


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

        # Distinguished name of subschema
        #
        # @return [String]
        #
        # @api public
        def sub_schema_entry
          root.first('subschemaSubentry')
        end

        # @return [Array<String>] Object classes known by directory
        #
        # @api public
        def schema_object_classes
          sub_schema['objectClasses'].sort
        end

        # Query directory for all known attribute types
        #
        # @return [Array<String>] Attribute types known by directory
        #
        # @api public
        def schema_attribute_types
          sub_schema['attributeTypes'].sort
        end

        # @return [Array<String>]
        #
        # @api public
        def supported_extensions
          root['supportedExtension'].sort
        end

        # @return [Array<String>]
        #
        # @api public
        def supported_controls
          root['supportedControl'].sort
        end

        # @return [Array<String>]
        #
        # @api public
        def supported_mechanisms
          root['supportedSASLMechanisms'].sort
        end

        # @return [Array<String>]
        #
        # @api public
        def supported_features
          root['supportedFeatures'].sort
        end

        # @return [Array<Integer>]
        #
        # @api public
        def supported_versions
          root['supportedLDAPVersion'].sort.map(&:to_i)
        end


        private


        # Representation of directory RootDSE
        #
        # @return [Directory::Entry]
        #
        # @raise [ResponseMissingError]
        #
        # @api private
        def root
          @root ||= query(
            base: EMPTY_BASE,
            scope: SCOPE_BASE_OBJECT,
            attributes: ROOT_DSE_ATTRS
          ).first
        end

        # Representation of directory SubSchema
        #
        # @return [Directory::Entry]
        #
        # @api private
        def sub_schema
          @sub_schema ||= query(
            base: sub_schema_entry,
            scope: SCOPE_BASE_OBJECT,
            filter: '(objectClass=subschema)',
            attributes:  %w[objectClasses attributeTypes],
            max_results: 1
          ).first
        end
      end
    end
  end
end
