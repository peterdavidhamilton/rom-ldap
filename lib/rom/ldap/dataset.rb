require 'net/ldap'

module ROM
  module Ldap
    class Dataset

      attr_accessor :connection

      def initialize(connection = nil)
        @connection ||= connection || Gateway.instance.connection
      end

      def call(filter = nil)
        begin
          entries_to_hashes connection.search(filter: filter)
        rescue ::Net::LDAP::Error
          logger.error '
          ====================================
          ROM::Ldap::Dataset connection failed
          ===================================='
        end
      end

      alias :[] :call

      private

      # convert Net::LDAP::Entry to hash
      def entries_to_hashes(array=[])
        array.map(&->(entry){entry.instance_variable_get(:@myhash)} )
      end

      def logger
        Gateway.instance.logger
      end
    end
  end
end
