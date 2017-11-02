require 'logger'
require 'rom/gateway'
require 'rom/ldap/dataset'

module ROM
  module LDAP
    # LDAP gateway
    #
    # @api public
    class Gateway < ROM::Gateway
      adapter :ldap

      # @!attribute [r] logger
      #   @return [Object] configured gateway logger
      attr_reader :logger

      # @!attribute [r] options
      #   @return [Hash] Options passed to API search
      attr_reader :options

      # Initialize an LDAP gateway
      #
      # Gateways are typically initialized via ROM::Configuration object
      #
      # @overload initialize(uri)
      #   Connects to a directory via params hash
      #
      #   @example
      #     ROM.container(:ldap, {})
      #
      #   @param [Hash]
      #
      # @overload initialize(uri, options)
      #   Connects to a database via URI and options
      #
      #   @example
      #     ROM.container(:ldap, {}, size: 100, time: 3)
      #
      #   @param [Hash] passed to Net::LDAP#new
      #
      #   @param options [Hash] default server options
      #
      #   @option options [Integer] :time Directory timeout in seconds
      #
      #   @option options [Integer] :size Directory result limit
      #
      # @overload initialize(connection)
      #   Creates a gateway from an existing directory connection.
      #   This works with Net::LDAP connections exclusively.
      #
      #   @example
      #     ROM.container(:ldap, Net::LDAP.new)
      #
      #   @param [Net::LDAP] connection a connection instance
      #
      # @return [LDAP::Gateway]
      #
      # @see https://github.com/ruby-ldap/ruby-net-ldap/blob/master/lib/net/ldap.rb
      #
      # @api public
      def initialize(directory = EMPTY_HASH, options = EMPTY_HASH)

        @username = directory[:username]
        @password = directory[:password]
        @base     = directory[:base]
        @server   = directory[:server]

        connect!

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

      # Underlying directory type
      #
      # @return [Symbol]
      #
      # @api public
      def database_type
        api.directory_type
      end

      alias directory_type database_type

      private

      # Wrapper for ROM::LDAP::Connection
      #
      # @return [Dataset::API] an api instance
      #
      # @api private
      def api
        @api ||= Dataset::API.new(connection, logger, options)
      end


      def connect!
        @conn = ROM::LDAP::Connection.new(server: @server)
      end


      def connection
        return @conn if @conn
        conn = connect!
        pdu  = conn.bind(username: @username, password: @password)
        pdu.success? ? conn : pdu
      end

    end
  end
end
