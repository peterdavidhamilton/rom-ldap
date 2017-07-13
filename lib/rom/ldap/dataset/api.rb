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

        def search(filter)
          fetch_or_store(filter.hash) do
            raw(filter: filter).map { |entry| extract_tuple(entry) }
          end
        end

        def raw(options, &block)
          logger.debug("#{self.class} #{options[:filter]}")
          result = connection.search(options, &block)
          log_status(__callee__)
          result
        end

        def bind_as(args)
          connection.bind_as(args)
        end

        def exist?(filter)
          raw(filter: filter, return_result: false)
        end

        # @return [Struct]
        #
        def add(tuple)
          params = tuple.dup
          connection.add(dn: params.delete(:dn), attributes: params)
          log_status(__callee__)
        end

        def modify(dn, operations)
          connection.modify(dn: dn, operations: operations)
          log_status(__callee__)
        end

        def delete(dn)
          connection.delete(dn: dn)
          log_status(__callee__)
        end

        private

        def log_status(caller=nil)
          logger.debug("#{self.class}##{caller} server: '#{host}:#{port}' base: '#{base}' code: #{status.code} result: '#{status.message}'")
          logger.error("#{self.class}##{caller} error: '#{error}'") unless error.empty?
        end

        # reveal Hash from Net::LDAP::Entry
        #
        # @return [Hash]
        #
        def extract_tuple(entry)
          entry.instance_variable_get(:@myhash)
        end

        def capabilities
          connection.search_root_dse
        end

        def host
          connection.host
        end

        def port
          connection.port
        end

        def base
          connection.base
        end

        # TODO: TBC access Net::LDAP connection auth info
        def auth
          connection.instance_variable_get(:@auth)
        end

        def status
          connection.get_operation_result
        end

        def error
          status.error_message
        end

        def pageable?
          connection.paged_searches_supported?
        end
      end
    end
  end
end
