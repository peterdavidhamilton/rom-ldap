# encoding: utf-8
# frozen_string_literal: true

# Returns array of hashes coerced from Ldap::Entries using a given filter
# filters:
# "(groupid=1025)"

module ROM
  module Ldap
    class Dataset
      # receive string
      # or filter class
      def call(filter)
        results = filter ? connection.search(filter: filter) : connection.search
        entries_to_hashes(results)
      rescue ::Net::LDAP::Error, ::Net::LDAP::ConnectionRefusedError, ::Errno::ECONNREFUSED
        logger.error 'rom-ldap failed to connect to server'
        []  # return empty array as result to dataset
      end

      alias [] call

      private

      # coerce Net::LDAP::Entry to hash
      #
      # @api private
      def entries_to_hashes(array = [])
        array.map(&->(entry) { entry.instance_variable_get(:@myhash) })
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
