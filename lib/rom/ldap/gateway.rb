require 'logger'
require 'dry/core/constants'

require 'rom/gateway'
require 'rom/ldap/dataset'

module ROM
  module LDAP
    # LDAP gateway
    #
    # @api public
    class Gateway < ROM::Gateway
      include Dry::Core::Constants

      adapter :ldap

      # @!attribute [r] client
      #   @return [Object, Hash] Net::LDAP client instance
      attr_reader :client

      # @!attribute [r] logger
      #   @return [Object] configured gateway logger
      attr_reader :logger

      # @!attribute [r] options
      #   @return [Hash] Options passed to API search
      attr_reader :options

      # Initialize an LDAP gateway
      #
      # Gateways are typically initialized via ROM::Configuration object, gateway constructor
      # arguments such as URI and options are passed directly to this constructor
      #
      # @overload initialize(uri)
      #   Connects to a database via URI
      #
      #   @example
      #     ROM.container(:ldap, {})
      #
      #   @param [String,Symbol] uri connection URI
      #
      # @overload initialize(uri, options)
      #   Connects to a database via URI and options
      #
      #   @example
      #     ROM.container(:ldap, {}, size: 100, time: 3)
      #
      #   @param [String,Symbol] uri connection URI
      #
      #   @param [Hash] options connection options
      #
      #   @option options [Array<Symbol>] :extensions
      #     A list of connection extensions supported by Sequel
      #
      #   @option options [Integer] :time Directory timeout in seconds
      #
      #   @option options [Integer] :size Directory result limit
      #
      # @overload initialize(connection)
      #   Creates a gateway from an existing database connection. This
      #   works with Net::LDAP connections exclusively.
      #
      #   @example
      #     ROM.container(:ldap, Net::LDAP.new)
      #
      #   @param [Net::LDAP] connection a connection instance
      #
      # @return [LDAP::Gateway]
      #
      # @see https://github.com/ruby-ldap/ruby-net-ldap/blob/master/lib/net/ldap.rb Net::LDAP docs
      #
      # @api public
      def initialize(server = EMPTY_HASH, options = EMPTY_HASH)
        @client  = connect(server)
        @options = options
        @logger  = options.fetch(:logger) { ::Logger.new(STDOUT) }

        super()
      end

      # Used by attribute_inferrer
      #
      # @param filter [String,Net::LDAP::Filter]
      #
      # @return [Array<Net::LDAP::Entry>]
      #
      # @api public
      def [](filter)
        api.attributes(filter) || EMPTY_ARRAY
      end

      # Directory attributes identifiers and descriptions
      #
      # @return [Array<String>]
      #
      # @api public
      def attribute_types
        api.attribute_types
      end

      # Disconnect from the gateway's directory
      #
      # @api public
      def disconnect
        api.disconnect
      end

      # Return dataset with the given name
      #
      # @param filter [String] a filtered dataset
      #
      # @return [Dataset]
      #
      # @api public
      def dataset(filter)
        Dataset.new(api, filter)
      end

      # @param logger [Logger]
      #
      # @api public
      def use_logger(logger)
        @logger = logger
      end


      private

      # Wrapper for Net::LDAP client
      #
      # @return [Dataset::API] an api instance
      #
      # @api private
      def api
        @api ||= Dataset::API.new(connection, logger, options)
      end

      # Connect to directory or reuse established connection instance
      #
      # @return [Net::LDAP] a client instance
      #
      # @param server [Hash,Net::LDAP] a client instance or params
      #
      # @api private
      def connect(server)
        case server
        when ::Net::LDAP
          server
        else
          ::Net::LDAP.new(server)
        end
      end

      # Bind to directory and rescue errors
      #
      # @return [Net::LDAP] a client instance
      #
      # @api private
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
