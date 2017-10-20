require 'rom/initializer'

# responsible for use of connection and logging
#
module ROM
  module LDAP
    class Dataset
      class API

        # PAGED_RESULTS = '1.2.840.113556.1.4.319'
        # SORT_REQUEST  = '1.2.840.113556.1.4.473'
        # SORT_RESPONSE = '1.2.840.113556.1.4.474'
        # DELETE_TREE   = '1.2.840.113556.1.4.805'
        # LDAP_MATCHING_RULE_BIT_AND = '1.2.840.113556.1.4.803'
        # LDAP_MATCHING_RULE_BIT_OR  = '1.2.840.113556.1.4.804'

        extend Initializer

        param :connection
        param :logger

        option :size, reader: :private, default: proc { 100 }
        option :time, reader: :private, default: proc { 3 }

        # Query results as array of hashes ordered by Distinguishing Name
        #
        # @param filter [String, Net::LDAP::Filter]
        # @param block
        # @return [Array <Hash>]
        # @api public
        #
        def search(filter, scope=nil, &block)
          options = {
            filter: filter,
            size: size,
            time: time,
						deref: Net::LDAP::DerefAliases_Always,
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
        # @return [Array <Net::LDAP::Entry>]
        # @api public
        #
        def directory(options, &block)
          connection.search(options, &block) or
            raise(LDAP::ConnectionError, 'directory returned nil')

          rescue *ERROR_MAP.keys => e
            raise ERROR_MAP.fetch(e.class, Error), e
        end

        def bind_as(args)
          connection.bind_as(args)
        end

        # @return [Integer]
        # @api public
        #
        def count(filter)
          directory(filter: filter, attributes: 'dn').count
        end

        # @return [Boolean]
        # @api public
        #
        def include?(filter, key)
          directory(filter: filter, attributes_only: true) do |e|
            binding.pry
            e.send(key)
          end
        end

        # @return [Boolean]
        # @api public
        #
        def exist?(filter)
          directory(filter: filter, return_result: false)
        end


        # Wrapper for Net::LDAP::Connection#add
        #
        # @param tuple [Hash]
        # @return [Boolean]
        # @api public
        #
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
        # @api public
        #
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
        # @return [Boolean]
        # @api public
        #
        def delete(dn)
          connection.delete(dn: dn)
          log(__callee__, dn)
          success?

          rescue *ERROR_MAP.keys => e
            raise ERROR_MAP.fetch(e.class, Error), e
        end

        private

        def log(caller = nil, message = nil)
          logger.error("#{self.class}##{caller} error: '#{error}'") unless success?
          logger.info("#{self.class}##{caller} #{message}")
          logger.debug("#{self.class}##{caller} code: #{status.code} result: '#{status.message}'") if ENV['DEBUG']
        end

        # Convenience method to prepare a tuple for #add
        #
        # @example
        #   prepare({'dn' => X, 'sn' => Y}) #=> [X, sn: Y]
        #
        # @param tuple [Hash]
        # @return [Array, <String> <Hash>]
        # @api private
        #
        def prepare(tuple)
          args = LDAP::Functions[:ldap_compatible][tuple.dup]
          dn   = args.delete(:dn)
          [dn, args]
        end

        # Reveal Hash from Net::LDAP::Entry
        #
        # @param entry [Net::LDAP::Entry]
        # @return [Hash]
        # @api private
        #
        def extract(entry)
          entry.instance_variable_get(:@myhash)
        end

        def capabilities
          connection.search_root_dse
        end

        # @return [String]
        # @api private
        #
        def host
          connection.host
        end

        # @return [String]
        # @api private
        #
        def port
          connection.port
        end

        # @return [String]
        # @api private
        #
        def base
          connection.base
        end

        def auth
          connection.instance_variable_get(:@auth)
        end

        def status
          connection.get_operation_result
        end

				def	detailed_status
					status.extended_response[0][0]
				end

        def success?
          status.code.zero?
        end

        def error
          status.error_message
        end

        # @return [Boolean]
        # @api private
        #
        def sortable?
          controls.include?(Net::LDAP::LDAPControls::SORT_RESPONSE)
        end

        # @return [Boolean]
        # @api private
        #
        def pageable?
          connection.paged_searches_supported?
        end

        # @return [Hash]
        # @api private
        #
        def controls
          connection.instance_variable_get(:@server_caps)[:supportedcontrol]
        end
      end
    end
  end
end
