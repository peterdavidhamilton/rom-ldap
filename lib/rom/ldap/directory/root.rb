module ROM
  module LDAP
    class Directory
      module Root
        # Set instance variables like directory_type
        #
        # @see Gateway#directory
        #
        # @return [ROM::LDAP::Directory]
        #
        # @api public
        def load_rootdse!
          case vendor_name
          when /Apache/
            @type = :apacheds
            require 'rom/ldap/directory/vendors/apache_ds'
          when /Apple/
            @type = :open_directory
            require 'rom/ldap/directory/vendors/open_directory'
          when /Novell/
            @type = :e_directory
            require 'rom/ldap/directory/vendors/e_directory'
          when /389/
            @type = :three_eight_nine
            require 'rom/ldap/directory/vendors/three_eight_nine'
          when nil
            caps = root['supportedCapabilities'].sort

            if caps.empty?
              logger.info("#{self.class} unknown Active Directory version")
            else
              require 'rom/ldap/directory/vendors/active_directory'

              dc     = root.first('domainControllerFunctionality').to_i
              forest = root.first('forestFunctionality').to_i
              dom    = root.first('domainFunctionality').to_i

              time   = Functions[:to_time][root['currentTime']].first

              @type                     = :active_directory
              @supported_capabilities   = caps
              @controller_functionality = dc
              @forest_functionality     = forest
              @domain_functionality     = dom
              @directory_time           = time # TODO: check against app time
              @vendor_name              = 'Microsoft'
              @vendor_version           = ActiveDirectory::VERSION_NAMES[dom]
            end

          else
            logger.info("#{self.class} unknown directory implementation")
            @type = :unknown
          end
          self
        end

        # @return [Symbol]
        #
        # @api public
        attr_reader :type

        private

        # Representation of directory RootDSE
        #
        # @return [Directory::Entry]
        #
        # @param attrs [Array<Symbol>] optional array of desired attributes
        #
        # @api private
        def root(*attrs)
          attrs = attrs.empty? ? ROOT_DSE_ATTRS : attrs

          query(
            base:       EMPTY_BASE,
            scope:      SCOPE_BASE_OBJECT,
            attributes: attrs,
            unlimited:  false
          ).first
        end

        # @return [Integer]
        #
        # @api private
        attr_reader :controller_functionality

        # @return [Integer]
        #
        # @api private
        attr_reader :domain_functionality

        # @return [Integer]
        #
        # @api private
        attr_reader :forest_functionality

        # LDAP server internal clock (Active Directory)
        #
        # @return [Time]
        #
        # @api private
        attr_reader :directory_time

        # @return [Array<String>]
        #
        # @api private
        attr_reader :supported_capabilities

        # @return [String]
        #
        # @api private
        def vendor_name
          @vendor_name ||= root.first('vendorName')
        end

        # @return [String]
        #
        # @api private
        def vendor_version
          @vendor_version ||= root.first('vendorVersion')
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_extensions
          root['supportedExtension'].sort
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_controls
          root['supportedControl'].sort
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_mechanisms
          root['supportedSASLMechanisms'].sort
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_features
          root['supportedFeatures'].sort
        end

        # @return [Array<Integer>]
        #
        # @api private
        def supported_versions
          root['supportedLDAPVersion'].sort.map(&:to_i)
        end
      end
    end
  end
end
