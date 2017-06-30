require 'rom/gateway'
require 'rom/ldap/dataset'
#
# responsible for connecting to the directory and handling failure
#
module ROM
  module Ldap
    class Gateway < ROM::Gateway

      def self.client(params = {})
        case params
        when ::Net::LDAP
          params
        else
          ::Net::LDAP.new(params)
        end
      end

      attr_reader :client

      # @!attribute [r] logger
      #   @return [Object] configured gateway logger
      attr_reader :logger

      # @!attribute [r] options
      #   @return [Hash] Options used for connection
      attr_reader :options


      def initialize(ldap_params, options = {})
        @client  = self.class.client(ldap_params)
        @options = options
        @logger  = options[:logger] || ::Logger.new(STDOUT)

        super()
      end

      # chains methods for the api to eventually call
      # name of table not applicable
      #
      def dataset(_name)
        Dataset.new(api)
      end

      # raw ldap search used by attribute_inferrer
      #
      # @api public
      def [](name)
        api.raw(name)
      end

      private

      def api
        Dataset::API.new(connection, logger)
      end

      def connection
        begin
          client.bind
        rescue ::Net::LDAP::ConnectionRefusedError,
               ::Errno::ECONNREFUSED,
               ::Net::LDAP::Error => e

          logger.error(e)
          abort "#{self.class.name} failed to bind - #{e.message}"
        else
          client
        end
      end
    end
  end
end
