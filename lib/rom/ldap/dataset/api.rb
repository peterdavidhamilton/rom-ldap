require 'rom/initializer'
# require 'rom/support/memoizable'

module ROM
  module LDAP
    class Dataset
      # LDAP Connection DSL
      #
      # wrapper for Net::LDAP::Connection
      #
      class API
        # include Memoizable
        extend Initializer

        param :connection
        param :logger

        option :size, reader: :private, default: proc { 100 }
        option :time, reader: :private, default: proc { 3 }

        attr_reader :directory_type

        def initialize(*)
          super
          inspect_server!
        end

        # Wrapper for Net::LDAP::Connection#search directory results
        #
        # @param options [Hash]
        #
        # @return [Array <Net::LDAP::Entry>]
        #
        # @api public
        def directory(options, &block)
          Timeout.timeout(options[:time]) do
            connection.search(options, &block) or
              raise(LDAP::ConnectionError, 'no dataset returned')
          end

          rescue *ERROR_MAP.keys => e
            raise ERROR_MAP.fetch(e.class, Error), e
          rescue Timeout::Error
            log(__callee__, "timed out after #{time} seconds", :warn)
            EMPTY_ARRAY
        end


        # Query results as array of hashes ordered by Distinguishing Name
        #
        # @param filter [String,Net::LDAP::Filter]
        #
        # @param scope
        #
        # @return [Array<Hash>]
        #
        # @api public
        # NB: scope is likely to always be nil because Dataset#search passes nil
        def search(filter, scope: SCOPE_SUBTREE, timeout: time, &block)
          options = {
            filter: filter,
            scope:  scope,
            size:   size,
            time:   timeout,
            deref:  DEREF_ALWAYS,
          }

          results = directory(options).sort_by(&:dn).map(&method(:extract))
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
        def bind_as(args)
          # { size: 1 }
          connection.bind_as(args)
        end


        # Used by gateway[filter]
        #
        # @return [Integer]
        #
        # @api public
        def attributes(filter, &block)
          options = { filter: filter, size: size, attributes_only: true }
          directory(options, &block)
        end

        # @return [Integer]
        #
        # @api public
        def count(filter)
          directory(filter: filter, attributes: 'dn').count
        end


        # @return [Boolean]
        #
        # @api public
        def exist?(filter)
          directory(filter: filter, return_result: false)
        end


        # Wrapper for Net::LDAP::Connection#add
        #
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

          rescue *ERROR_MAP.keys => e
            raise ERROR_MAP.fetch(e.class, Error), e
        end

        # Wrapper for Net::LDAP::Connection#modify
        #
        # @return [Boolean]
        #
        # @api public
        def modify(dn, operations)
          connection.modify(dn: dn, operations: operations)
          log(__callee__, dn)
          success?

          rescue *ERROR_MAP.keys => e
            raise ERROR_MAP.fetch(e.class, Error), e
        end

        # Wrapper for Net::LDAP::Connection#delete
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

          rescue *ERROR_MAP.keys => e
            raise ERROR_MAP.fetch(e.class, Error), e
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
            caps = root.fetch(:supportedcapabilities, EMPTY_ARRAY).sort

            unless caps.empty?
              require 'rom/ldap/implementations/active_directory'

              dc     = root.fetch(:domaincontrollerfunctionality).first.to_i
              forest = root.fetch(:forestfunctionality).first.to_i
              dom    = root.fetch(:domainfunctionality).first.to_i

              @supported_capabilities   = caps
              @controller_functionality = dc
              @forest_functionality     = forest
              @domain_functionality     = dom


              @vendor_name    = 'Microsoft'
              @vendor_version = ActiveDirectory::VERSION_NAMES[dom]
              @directory_type = :active_directory
            else
              log(__callee__, 'Active Directory version is unknown')
            end

          else
            log(__callee__, "LDAP implementation #{vendor_name} is unknown")
            @directory_type = :unknown
          end
        end



        # Returns all known attributes if no param provided
        #
        # @return [Array<String>]
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

          # favour real hashes over Entry classes
          ).first.instance_variable_get(:@myhash)
        end


        def sub_schema
          @sub_schema ||= directory(
            base: sub_schema_entry,
            scope: SCOPE_BASE_OBJECT,
            filter: 'objectclass=subschema',
            attributes: %w[objectclasses attributetypes],
            ignore_server_caps: true,

          # favour real hashes over Entry classes
          ).first.instance_variable_get(:@myhash)
        end



        def log(caller = nil, message = nil, level = :info)
          logger.send(level, "#{self.class}##{caller} #{message}")
          logger.error("#{self.class}##{caller} #{status.message}") unless success?
          logger.debug("#{self.class}##{caller} #{status.message}") if ENV['DEBUG']
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

        # Reveal Hash from Net::LDAP::Entry
        #   TODO: replace use of Entry class with a dry-struct
        #
        # @param entry [Net::LDAP::Entry]
        #
        # @return [Hash]
        #
        # @api private
        def extract(entry)
          entry.instance_variable_get(:@myhash)
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
            name:        attribute_name.to_sym,
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
          @vendor_name ||= root.fetch(:vendorname, EMPTY_ARRAY).first
        end

        # @result [String]
        #
        # @api private
        def vendor_version
          @vendor_version ||= root.fetch(:vendorversion, EMPTY_ARRAY).first
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_extensions
          @supported_extensions ||= root.fetch(:supportedextension).sort
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_controls
          @supported_controls ||= root.fetch(:supportedcontrol).sort
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_mechanisms
          @supported_mechanisms ||= root.fetch(:supportedsaslmechanisms).sort
        end

        # @return [Array<String>]
        #
        # @api private
        def supported_features
          @supported_features ||= root.fetch(:supportedfeatures).sort
        end

        # @return [Array<Integer>]
        #
        # @api private
        def supported_versions
          @supported_versions ||= root.fetch(:supportedldapversion).sort.map(&:to_i)
        end


        # memoize :attribute_types,
        #         :sub_schema,
        #         :sub_schema_entry
        #         :supported_versions,
        #         :supported_features,
        #         :supported_mechanisms,
        #         :supported_controls,
        #         :supported_extensions,
        #         :vendor_name,
        #         :vendor_version

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
          @sub_schema_entry ||= root.fetch(:subschemasubentry, EMPTY_ARRAY).first
        end


        # @return [Array<String>] Object classes known by directory
        #
        # @api private
        def schema_object_classes
          sub_schema[:objectclasses].sort
        end

        # Query directory for all known attribute types
        #
        # @return [Array<String>] Attribute types known by directory
        #
        # @api private
        def schema_attribute_types
          sub_schema[:attributetypes].sort
        end

        # TODO: docs for known_attributes
        # @api private
        def known_attributes
          directory(
            filter: '(objectclass=*)',
            base: EMPTY_BASE
          ).flat_map { |a| a.attribute_names }.uniq.sort
        end

        # @return [String]
        #
        # @api private
        def host
          connection.host
        end

        # @return [String]
        #
        # @api private
        def port
          connection.port
        end

        # @return [String]
        #
        # @api private
        def base
          connection.base
        end

        def auth
          connection.instance_variable_get(:@auth)
        end

        # deprecate
        def status
          # connection.instance_variable_get(:@result) # wrapped in struct
          connection.get_operation_result
        end

        def detailed_status
          status.extended_response[0][0]
        end

        # @return [Boolean]
        #
        # @api private
        def success?
          result.result_code.to_i.zero?
        end

        # WIP - uncouple connection result
        #
        # @return [Net::LDAP::PDU]
        #
        #<Net::LDAP::PDU:0x00007f811c801318 @message_id=2, @app_tag=5, @ldap_controls=[], @ldap_result={:resultCode=>0, :matchedDN=>"", :errorMessage=>""}>
        #
        def result
          connection.instance_variable_get(:@result)
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
      end
    end
  end
end
