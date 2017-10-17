require 'rom/initializer'
require 'dry/core/cache'
#
# responsible for use of connection and logging
#
module ROM
  module LDAP
    class Dataset
      class API
        extend Initializer
        extend Dry::Core::Cache

        param :connection
        param :logger

        # @param filter [String, Net::LDAP::Filter]
        # @return [Array <Hash>]
        # @api public
        #
        def search(filter)
          fetch_or_store(filter.to_s) do
            raw(
              filter: filter,
              return_referrals: true,
              return_result: true,
              paged_searches_supported: pageable?,
              # FIXME: not working on AD and breaks apacheds
              # sort_controls: ['dn', 'cn'],
            ).sort_by(&:dn).map { |t| extract_tuple(t) }
          end
        end

        # Net::LDAP::Client search returning raw results ordered by DN
        #
        # @param options [Hash]
        # @return [Array <Net::LDAP::Entry>]
        # @api public
        #
        def raw(options, &block)
          logger.info("#{self.class} #{options[:filter]}")
          result = connection.search(options, &block)
          log_status(__callee__)
          result or raise(LDAP::FilterError, 'dataset could not be found')
        end

        def bind_as(args)
          connection.bind_as(args)
        end

        # @return [Boolean]
        # @api public
        #
        def exist?(filter)
          raw(filter: filter, return_result: false)
        end

        # @param tuple [Hash]
        # @return [Struct]
        # @api public
        #
        def add(tuple)
          params = LDAP::Functions[:ldap_compatible][tuple.dup]
          connection.add(dn: params.delete(:dn), attributes: params)
          log_status(__callee__)
          rescue *ERROR_MAP.keys => e
            raise ERROR_MAP.fetch(e.class, Error), e
        end

        # @return [Struct]
        # @api public
        #
        def modify(dn, operations)
          connection.modify(dn: dn, operations: operations)
          log_status(__callee__)
          rescue *ERROR_MAP.keys => e
            raise ERROR_MAP.fetch(e.class, Error), e
        end

        # @return [Struct]
        # @api public
        #
        def delete(dn)
          connection.delete(dn: dn)
          log_status(__callee__)
          rescue *ERROR_MAP.keys => e
            raise ERROR_MAP.fetch(e.class, Error), e
        end

        private

        def log_status(caller=nil)
          logger.info("#{self.class}##{caller} server: '#{host}:#{port}' base: '#{base}' code: #{status.code} result: '#{status.message}'")
          logger.error("#{self.class}##{caller} error: '#{error}'") unless error.empty?
        end

        # reveal Hash from Net::LDAP::Entry
        #
        # @param entry [Net::LDAP::Entry]
        # @return [Hash]
        # @api private
        #
        def extract_tuple(entry)
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
