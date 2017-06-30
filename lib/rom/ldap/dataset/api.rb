require 'rom/initializer'
require 'dry/core/cache'
#
# responsible for use of connection and logging
#
module ROM
  module Ldap
    class Dataset
      class API

        extend Initializer
        extend Dry::Core::Cache

        param :connection
        param :logger

        def search(filter)
          logger.debug("#{self.class.name} filter: #{filter}")

          fetch_or_store(filter.hash) do
            raw(filter).map { |entry| extract_tuple(entry) }
          end
        end

        def raw(filter=nil)
          result = connection.search(filter: filter)
          log_status
          result
        end

        # reveal Hash from Net::LDAP::Entry
        #
        def extract_tuple(entry)
          entry.instance_variable_get(:@myhash)
        end

        def log_status
          logger.debug("#{self.class.name} host: '#{host}' port: '#{port}' base: '#{base}' result: '#{status.message}'")
        end

        private

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

        def pageable?
          connection.paged_searches_supported?
        end
      end
    end
  end
end
