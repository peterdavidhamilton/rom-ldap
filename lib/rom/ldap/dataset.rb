# encoding: utf-8
# frozen_string_literal: true

# Returns array of hashes coerced from Ldap::Entries using a given filter
# filters:
# "(groupid=1025)"

module ROM
  module Ldap
    class Dataset

      # @param [String, Net::LDAP::Filter]
      #
      # @return [Array<Hash>] - empty if no results or connection fails
      #
      # @api public
      #
      def call(filter)
        begin
          logger.debug(filter)
          connection.bind                           # check connection
        rescue ::Net::LDAP::ConnectionRefusedError, # server down (DEPRECATED)
               ::Errno::ECONNREFUSED,               # server down
               ::Net::LDAP::Error => error          # timeouts

          logger.error(error)
          []
        else
          entries_to_hashes search_ldap(filter)
        end
      end

      alias [] call

      private

      # @param [String, Net::LDAP::Filter]
      #
      # @return [Array<Net::LDAP::Entry>]
      #
      # @api private
      #
      def search_ldap(filter)
        filter ? connection.search(filter: filter) : connection.search
      end

      # @param [Array<Net::LDAP::Entry>]
      #
      # @return [Array<Hash>]
      #
      # @api private
      #
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
