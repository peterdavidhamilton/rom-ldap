module ROM
  module LDAP
    class Directory
      module SubSchema
        private

        # Struct/Hash like object representing an LDAP entity for SubSchema
        #
        def sub_schema
          query(
            base:       sub_schema_entry,
            scope:      SCOPE_BASE_OBJECT,
            filter:     '(objectclass=subschema)',
            attributes: %w[objectclasses attributetypes],
            unlimited:  false
          ).first
        end

        # @return [String]
        #
        # @api private
        def sub_schema_entry
          root.first('subschemaSubentry')
        end

        # @return [Array<String>] Object classes known by directory
        #
        # @api private
        def schema_object_classes
          sub_schema['objectClasses'].sort
        end

        # Query directory for all known attribute types
        #
        # @return [Array<String>] Attribute types known by directory
        #
        # @api private
        def schema_attribute_types
          sub_schema['attributeTypes'].sort
        end

      end
    end
  end
end
