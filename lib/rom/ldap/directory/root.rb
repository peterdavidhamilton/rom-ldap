module ROM
  module LDAP
    class Directory

      module Root
        # Identify the LDAP server vendor, type determines vendor extension to load.
        #
        # @see https://ldapwiki.com/wiki/Determine%20LDAP%20Server%20Vendor
        #
        # @return [Symbol]
        #
        # @api public
        def type
          case root.first('vendorName')
          when /389/        then :three_eight_nine
          when /Apache/     then :apache_ds
          when /Apple/      then :open_directory
          when /ForgeRock/  then :open_dj
          when /IBM/        then :ibm
          when /Netscape/   then :netscape
          when /Novell/     then :e_directory
          when /Oracle/     then :open_ds
          when /Sun/        then :sun_microsystems
          when nil
            return :active_directory if ad?
            return :open_ldap if od?
          else
            :unknown
          end
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

        # @example
        #   [ 'Apple', '510.30' ]
        #   [ 'Apache Software Foundation', '2.0.0-M24' ]
        #
        # @return [Array<String>]
        #
        # @api public
        def vendor
          [vendor_name, vendor_version]
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

        # @return [String]
        #
        # @api public
        def contexts
          root['namingContexts'].sort
        end

        private

        # Representation of directory RootDSE
        #
        # @see https://ldapwiki.com/wiki/Retrieving%20RootDSE
        #
        # @return [Directory::Entry]
        #
        # @raise [ResponseMissingError]
        #
        # @api private
        def root
          @root ||= query(
            base: EMPTY_STRING,
            scope: SCOPE_BASE,
            attributes: ALL_ATTRS
          ).first

          @root || raise(ResponseMissingError, 'Directory root failed to load')
        end

        # Representation of directory SubSchema
        #
        # @return [Directory::Entry]
        #
        # @raise [ResponseMissingError]
        #
        # @api private
        def sub_schema
          @sub_schema ||= query(
            base: sub_schema_entry,
            scope: SCOPE_BASE,
            attributes:  %w[objectClasses attributeTypes],
            filter: '(objectClass=subschema)',
            max_results: 1
          ).first

          @sub_schema || raise(ResponseMissingError, 'Directory schema failed to load')
        end

        # Check if vendor identifies as ActiveDirectory
        #
        # @return [TrueClass, FalseClass]
        #
        # @api private
        def ad?
          !root['forestFunctionality'].nil?
        end

        # Check if vendor identifies as OpenLDAP
        #
        # @return [TrueClass, FalseClass]
        #
        # @api private
        def od?
          root['objectClass']&.include?('OpenLDAProotDSE')
        end
      end

    end
  end
end
