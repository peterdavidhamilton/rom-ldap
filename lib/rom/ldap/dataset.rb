# encoding: utf-8
# frozen_string_literal: true

# Returns array of hashes coerced from Ldap::Entries using a given filter
# filters:
# "(groupid=1025)"

module ROM
  module Ldap
    class Dataset
      # receive string or filter class
      #
      # @api public
      def call(filter)
        results = search_ldap(filter)
        entries_to_hashes(results)

        # connection.paged_searches_supported?
      end

      alias [] call

      private

      # return enumerable collection, empty if connection fails
      #
      # @api private
      def search_ldap(filter)
        begin
          results = filter ? connection.search(filter: filter) : connection.search
        rescue ::Net::LDAP::Error,
               ::Net::LDAP::ConnectionRefusedError,
               ::Errno::ECONNREFUSED
          logger.error 'rom-ldap failed to connect to server'
        end
        connection.bind ? results : []
      end

      # coerce Net::LDAP::Entry to hash
      #
      # @api private
      def entries_to_hashes(results)
        results.map(&->(entry) { entry.instance_variable_get(:@myhash) })
      end

      def logger
        Gateway.instance.logger
      end

      def connection
        Gateway.instance.connection
      end
    end
  end
end
