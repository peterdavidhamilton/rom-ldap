require 'rom/initializer'

module ROM
  module LDAP
    class Dataset
      # LDAP Connection DSL
      #
      class API
        #
        # LDAP OID Controls
        #
        MICROSOFT_OID_PREFIX       = '1.2.840.113556'.freeze
        PAGED_RESULTS              = '1.2.840.113556.1.4.319'.freeze
        SHOW_DELETED               = '1.2.840.113556.1.4.417'.freeze
        SORT_REQUEST               = '1.2.840.113556.1.4.473'.freeze
        SORT_RESPONSE              = '1.2.840.113556.1.4.474'.freeze
        NOTIFICATION_OID           = '1.2.840.113556.1.4.528'.freeze
        MATCHING_RULE_BIT_AND      = '1.2.840.113556.1.4.803'.freeze
        MATCHING_RULE_BIT_OR       = '1.2.840.113556.1.4.804'.freeze
        DELETE_TREE                = '1.2.840.113556.1.4.805'.freeze
        DIRSYNC_OID                = '1.2.840.113556.1.4.841'.freeze
        PERMISSIVE_MODIFY          = '1.2.840.113556.1.4.1413'.freeze
        PASSWORD_POLICY_REQUEST    = '1.3.6.1.4.1.42.2.27.8.5.1'.freeze
        SUBENTRIES                 = '1.3.6.1.4.1.4203.1.10.1'.freeze
        MANAGED_SA_IT              = '2.16.840.1.113730.3.4.2'.freeze
        PERSISTENT_SEARCH          = '2.16.840.1.113730.3.4.3'.freeze
        VIRTUAL_LIST_VIEW_REQUEST  = '2.16.840.1.113730.3.4.9'.freeze
        VIRTUAL_LIST_VIEW_RESPONSE = '2.16.840.1.113730.3.4.10'.freeze
        PROXIED_AUTHORIZATION      = '2.16.840.1.113730.3.4.18'.freeze

        #
        # Default Global Filters
        #
        GROUPS = '(|(objectClass=group)(objectClass=groupOfNames))'.freeze
        USERS  = '(|(objectClass=inetOrgPerson)(objectClass=user))'.freeze

        extend Initializer

        param :connection
        param :logger

        option :size, reader: :private, default: proc { 100 }
        option :time, reader: :private, default: proc { 3 }

        # Query results as array of hashes ordered by Distinguishing Name
        #
        # @param filter [String,Net::LDAP::Filter]
        #
        # @param scope
        #
        # @return [Array<Hash>]
        #
        # @api public
        def search(filter, scope=nil, &block)
          options = {
            filter: filter,
            size: size,
            time: time,
            deref: Net::LDAP::DerefAliases_Always,
            paged_searches_supported: pageable?,
            return_referrals: true,
            return_result: true,
          }

          options.merge!(scope: scope)

          results = directory(options).sort_by(&:dn).map(&method(:extract))
          log(__callee__, filter)

          block_given? ? results.each(&block) : results
        end

        # Wrapper for Net::LDAP::Connection#search directory results
        #
        # @param options [Hash]
        #
        # @return [Array <Net::LDAP::Entry>]
        #
        # @api public
        def directory(options, &block)
          connection.search(options, &block) or
            raise(LDAP::ConnectionError, 'directory returned nil')

          rescue *ERROR_MAP.keys => e
            raise ERROR_MAP.fetch(e.class, Error), e
        end

        def bind_as(args)
          connection.bind_as(args)
        end

        # Used by gateway[filter]
        #
        # @return [Integer]
        #
        # @api public
        def attributes(filter, &block)
          options = {
            filter: filter,
            size: size,
            time: time,
            # sort_controls: ['dn'],
            attributes_only: true
          }

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
        # def include?(filter, key)
        #   attributes(filter) { |e| e.send(key) }
        # end

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
          all_attributes.flat_map { |type|
            parse_attribute_type(type)
          }.reject(&:nil?).sort_by { |a| a[:name] }
        end

        private

        def log(caller = nil, message = nil)
          logger.info("#{self.class}##{caller} #{message}")
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
          return unless name = type[/NAME '(\S+)'/, 1]
          {
            name:        name.to_sym,
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


        # @return [Array<String>]
        #
        # @api private
        def extensions
          connection.search_root_dse.supportedextension
        end

        # @return [Array<String>]
        #
        # @api private
        def controls
          connection.search_root_dse.supportedcontrol
        end

        # @return [Array<String>]
        #
        # @api private
        def mechanisms
          connection.search_root_dse.supportedsaslmechanisms
        end

        # @return [Array<String>]
        #
        # @api private
        def features
          connection.search_root_dse.supportedfeatures
        end

        # @return [Integer]
        #
        # @api private
        def ldap_version
          connection.search_root_dse.supportedldapversion.first.to_i
        end

        # @return [Array<String>] Object classes known by directory
        #
        # @api private
        def object_classes
          connection.search_subschema_entry[:objectclasses]
        end

        # Query directory for all known attribute types
        #
        # @return [Array<String>] Attribute types known by directory
        #
        # @api private
        def all_attributes
          connection.search_subschema_entry[:attributetypes]
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

        def status
          connection.get_operation_result
        end

        def detailed_status
          status.extended_response[0][0]
        end

        # @return [Boolean]
        #
        # @api private
        def success?
          status.code.zero?
        end

        # @return [Boolean]
        #
        # @api private
        def sortable?
          controls.include?(SORT_RESPONSE)
        end

        # @return [Boolean]
        #
        # @api private
        def pageable?
          connection.paged_searches_supported?
        end

      end
    end
  end
end
