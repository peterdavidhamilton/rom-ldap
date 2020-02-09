require 'rom/ldap/ldif/importer'
require 'rom/ldap/ldif/exporter'

require 'rom/initializer'
#
# @see https://docs.oracle.com/cd/E10773_01/doc/oim.1014/e10531/ldif_appendix.htm
#
module ROM
  module LDAP
    module_function

    #
    # LDAP Data Interchange Format (LDIF)
    #
    # Refines Array and Hash with #to_ldif method.
    #
    # @see Directory::Entry
    # @see Relation::Exporting
    #
    module LDIF
      # @example
      #
      #   ROM::LDAP::LDIF("version: 3\n") => [{}]
      #
      # @param ldif [String]
      #
      # @return [Array<Hash>]
      #
      # @api private
      def self.to_tuples(ldif, &block)
        Importer.new(ldif).to_tuples(&block)
      end

      # Extend functionality of Hash class.
      #
      refine ::Hash do
        # Convert hash to LDIF format
        #
        # @return [String]
        #
        # @api public
        def to_ldif
          Exporter.new([self]).to_ldif
        end
      end

      # Extend functionality of Array class.
      #
      refine ::Array do
        # Convert array to LDIF format
        #
        # @return [String]
        #
        # @api public
        def to_ldif
          Exporter.new(self).to_ldif
        end
      end
    end

    # Parser for LDIF format
    # rubocop:disable Naming/MethodName
    #
    # alias for LDIF.to_tuples
    #
    # @api public
    def LDIF(ldif, &block)
      LDIF.to_tuples(ldif, &block)
    end
    # rubocop:enable Naming/MethodName
  end
end
