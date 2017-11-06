# TODO: Divide the API between Gateway and Dataset concerns.
# Split methods into modules for inclusion in Gateway or Dataset.

require 'rom/initializer'
# require 'rom/support/memoizable'

module ROM
  module LDAP
    class Dataset
      # LDAP Connection DSL
      #
      # wrapper for ROM::LDAP::Connection
      #
      class API
        # include Memoizable
        extend Initializer

        param :connection
        param :logger

        attr_reader :directory_type

        def initialize(*)
          super
          inspect_server!
        end


        # @param options [Hash]
        #
        # @return [Array<Hash>]
        #
        # @api public
        def directory(options, &block) # TODO: rename call
          result_set = []
          @result = connection.search(options) do |entry|
            result_set << entry
            yield entry if block_given?
          end
          result_set.sort_by(&:dn)
        end

        attr_reader :result # PDU object

        # Query results as array of hashes ordered by Distinguishing Name
        #
        # @param filter [String]
        #
        # @param scope
        #
        # @return [Array<Hash>]
        #
        # @api public
        def search(filter, &block)
          options = { filter: filter, deref:  DEREF_ALWAYS }

          results = directory(options)
          log(__callee__, filter)

          block_given? ? results.each(&block) : results
        end


        # TODO: documentation
        #
        # @param args [Hash]
        #
        # @return
        #
        # @api public
        def bind_as(filter:, password:)
          connection.bind_as(filter: filter, password: password)
        end


        # Used by gateway[filter]
        #
        # @return [Integer]
        #
        # @api public
        def attributes(filter)
          directory(filter: filter, attributes_only: true)
        end

        # @return [Integer]
        #
        # @api public
        def count(filter)
          directory(filter: filter, attributes: 'dn', size: 1_000_000).count
        end


        # @return [Boolean]
        #
        # @api public
        def exist?(filter)
          directory(filter: filter, return_result: false)
        end


        # @param tuple [Hash]
        #
        # @return [Boolean]
        #
        # @api public
        def add(tuple)
          dn, args = prepare(tuple)
          connection.add(dn: dn, attributes: args)
          log(__callee__, dn)
          success?
        end


        #
        # @return [Boolean]
        #
        # @api public
        def modify(dn, operations)
          connection.modify(dn: dn, operations: operations)
          log(__callee__, dn)
          success?
        end

        #
        # @param dn [String]
        #
        # @return [Boolean]
        #
        # @api public
        def delete(dn)
          connection.delete(dn: dn)
          log(__callee__, dn)
          success?
        end

        # @result [Array<String>]
        #
        # @example
        #   [ "Apple", "510.30" ]
        #   [ "Apache Software Foundation", "2.0.0-M24" ]
        #
        # @api public
        def vendor
          [vendor_name, vendor_version]
        end

        # Disconnect from the gateway's directory
        #
        # @api public
        def disconnect
          connection.close
        end

        # Directory attributes identifiers and descriptions
        #
        # @return [Array<Hash>]
        #
        # @api public
        def attribute_types
          @attribute_types ||= schema_attribute_types.flat_map { |type|
            parse_attribute_type(type)
          }.reject(&:nil?).sort_by { |a| a[:name] }
        end

        private

        # Set instance variables like directory_type
        #
        # @return [self]
        #
        # @api private
        def inspect_server!
          case vendor_name
          when /Apache/
            @directory_type = :apacheds
          when /Apple/
            @directory_type = :open_directory
            require 'rom/ldap/implementations/open_directory'
          when /Novell/
            @directory_type = :e_directory
            require 'rom/ldap/implementations/e_directory'
          when /389/
            @directory_type = :three_eight_nine
          when nil
            caps = root['supportedCapabilities'].sort

            unless caps.empty?
              require 'rom/ldap/implementations/active_directory'

              dc     = root.first('domainControllerFunctionality').to_i
              forest = root.first('forestFunctionality').to_i
              dom    = root.first('domainFunctionality').to_i

              @supported_capabilities   = caps
              @controller_functionality = dc
              @forest_functionality     = forest
              @domain_functionality     = dom
              @vendor_name              = 'Microsoft'
              @vendor_version           = ActiveDirectory::VERSION_NAMES[dom]
              @directory_type           = :active_directory
            else
              log(__callee__, 'Active Directory version is unknown')
            end

          else
            log(__callee__, "LDAP implementation #{vendor_name} is unknown")
            @directory_type = :unknown
          end

          self
        end



        # Struct/Hash like object representing an LDAP entity for RootDSE
        #
        # @return [BER::Struct]
        #
        # @param attrs [Array<Symbol>] optional array of desired attributes
        #
        # @api private
        def root(*attrs)
          attrs = attrs.empty? ? ROOT_DSE_ATTRS : attrs

          directory(
            base: EMPTY_BASE,
            scope: SCOPE_BASE_OBJECT,
            attributes: attrs,
            ignore_server_caps: true
          ).first
        end

        # Struct/Hash like object representing an LDAP entity for SubSchema
        #
        def sub_schema
          @sub_schema ||= directory(
            base: sub_schema_entry,
            scope: SCOPE_BASE_OBJECT,
            filter: '(objectclass=subschema)',
            attributes: %w[objectclasses attributetypes],
            ignore_server_caps: true,
          ).first
        end

        def log(caller = nil, message = nil, level = :info)
          logger.send(level, "#{self.class}##{caller} #{message}")
          logger.error("#{self.class}##{caller} #{result.error_message}") unless success?
          logger.debug("#{self.class}##{caller} #{result.message}") if ENV['DEBUG']
        end

        # Convenience method to prepare a tuple for #add
        #
        # @example
        #   prepare({'dn' => X, 'sn' => Y})
        #     # => [X, sn: Y]
        #
        # @param tuple [Hash]
        #
        # @return [Array, <String> <Hash>]
        #
        # @api private
        def prepare(tuple)
          args = LDAP::Functions[:ldap_compatible][tuple.dup]
          dn   = args.delete(:dn)
          [dn, args]
        end

        # Build hash from attribute definition
        #   used by TypeBuilder
        #
        # @example
        #   parse_attribute_type("...")
        #     #=> { name: :uidnumber, description: '', single: true)
        #
        # @param type [String]
        #
        # @return [Hash]
        #
        # @api private
        def parse_attribute_type(type)
          return unless attribute_name = type[/NAME '(\S+)'/, 1]
          {

            # current net/ldap canonicalisation
            name:        attribute_name.downcase.to_sym,

            # unedited
            # name:        attribute_name,

            description: type[/DESC '(.+)' [A-Z]+/, 1],
            oid:         type[/SYNTAX (\S+)/, 1].tr("'", ''),
            matcher:     type[/EQUALITY (\S+)/, 1],
            substr:      type[/SUBSTR (\S+)/, 1],
            ordering:    type[/ORDERING (\S+)/, 1],
            single:      !type.scan(/SINGLE-VALUE/).empty?,
            modifiable:  !type.scan(/NO-USER-MODIFICATION/).empty?,
            usage:       type[/USAGE (\S+)/, 1],
            source:      type[/X-SCHEMA '(\S+)'/, 1],
          }
        end


        # @result [String]
        #
        # @api private
        def vendor_name
          @vendor_name ||= root.first('vendorName')
        end

        # @result [String]
        #
        # @api private
        def vendor_version
          @vendor_version ||= root.first('vendorVersion')
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_extensions
          @supported_extensions ||= root['supportedExtension'].sort
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_controls
          @supported_controls ||= root['supportedControl'].sort
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_mechanisms
          @supported_mechanisms ||= root['supportedSASLMechanisms'].sort
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_features
          @supported_features ||= root['supportedFeatures'].sort
        end

        # @return [Array<Integer>]
        #
        # @api private
        def supported_versions
          @supported_versions ||= root['supportedLDAPVersion'].sort.map(&:to_i)
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

        # @return [Array<String>]
        #
        # @api private
        attr_reader :supported_capabilities


        # @return [String]
        #
        # @api private
        def sub_schema_entry
          @sub_schema_entry ||= root.first('subschemaSubentry')
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

        # @api private
        def known_attributes
          binding.pry
          directory(
            filter: '(objectclass=*)',
            base: EMPTY_BASE
            # base: SCOPE_SUBTREE
          ).flat_map(&:attribute_names).uniq.sort
        end

        # # @return [String]
        # #
        # # @api private
        # def host
        #   connection.host
        # end

        # # @return [Integer]
        # #
        # # @api private
        # def port
        #   connection.port
        # end

        # # @return [String]
        # #
        # # @api private
        # def base
        #   connection.base
        # end

        def detailed_status
          result.extended_response[0][0]
        end

        # @return [Boolean]
        #
        # @api private
        def success?
          result.success?
        end

        # @return [Boolean]
        #
        # @api private
        def sortable?
          supported_controls.include?(SORT_RESPONSE)
        end

        # @return [Boolean]
        #
        # @api private
        def pageable?
          supported_controls.include?(PAGED_RESULTS)
        end

        # Active Directory
        # controls.include?(MATCHING_RULE_IN_CHAIN)
        # controls.include?(DELETE_TREE)

        # Active Directory only
        #
        # @return [Boolean]
        #
        # @api private
        def bitwise?
          supported_controls.include?(MATCHING_RULE_BIT_AND) &&
          supported_controls.include?(MATCHING_RULE_BIT_OR)
        end




        # memoize :attribute_types,
        #         :sub_schema,
        #         :sub_schema_entry,
        #         :supported_versions,
        #         :supported_features,
        #         :supported_mechanisms,
        #         :supported_controls,
        #         :supported_extensions,
        #         :vendor_name,
        #         :vendor_version
      end
    end
  end
end
