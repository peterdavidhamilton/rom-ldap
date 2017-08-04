require 'rom/gateway'
require 'rom/ldap/dataset'
#
# responsible for connecting to the directory and handling failure
#
module ROM
  module LDAP
    class Gateway < ROM::Gateway

      def self.client(params={})
        case params
        when ::Net::LDAP
          params
        else
          ::Net::LDAP.new(params)
        end
      end

      # @!attribute [r] client
      #   @return [Object] Net::LDAP cient
      attr_reader :client

      # @!attribute [r] logger
      #   @return [Object] configured gateway logger
      attr_reader :logger

      # @!attribute [r] options
      #   @return [Hash] Options used for connection
      attr_reader :options


      def initialize(ldap_params, options={})
        @client  = self.class.client(ldap_params)
        @options = options
        @logger  = options.fetch(:logger) { ::Logger.new(STDOUT) }

        super()
      end

      def dataset(table)
        Dataset.new(api, table)
      end

      # raw ldap search used by attribute_inferrer
      #
      # @api public
      def [](filter)
        api.raw(filter: filter)
      end

      # @api public
      def use_logger(logger)
        @logger = logger
      end

      #
      def object_classes
        connection.search_subschema_entry[:objectclasses]
      end

      # used by AttributesInferrer
      #
      def attribute_types
        connection.search_subschema_entry[:attributetypes]
      end

      private

      # wrapper for Net::LDAP client
      #
      def api
        @api ||= Dataset::API.new(connection, logger)
      end

      def connection
        begin
          client.bind
        rescue *ERROR_MAP.keys => e
          raise ERROR_MAP.fetch(e.class, Error), e
        else
          client
        end
      end
    end
  end
end
