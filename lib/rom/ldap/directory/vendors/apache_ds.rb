# frozen_string_literal: true

module ROM
  module LDAP
    #
    # Apache Directory Extension
    #
    # @api private
    module ApacheDs
      # IGNORE_ATTRS_REGEX = /^[m-|ads|entry].*$/.freeze

      # @return [Array]
      #
      # @api public
      def schema_attributes
        query(base: 'ou=schema', filter: '(objectClass=metaAttributeType)')
      end

      # @return [Array]
      #
      # @api public
      def schemas_classes
        query(base: 'ou=schema', filter: '(objectClass=metaObjectClass)')
      end
    end
  end
end
