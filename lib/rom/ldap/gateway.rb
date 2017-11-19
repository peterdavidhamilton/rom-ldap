require 'logger'
require 'rom/gateway'
require 'rom/ldap/directory'
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
      #   @return [Hash] Options passed to directory
      attr_reader :options

      # @!attribute [r] options
      #   @return [Hash] Options passed to connection
      attr_reader :server

      # Initialize an LDAP gateway
      #
      # Gateways are typically initialized via ROM::Configuration object
      #
      # @overload initialize(params)
      #   Connects to a directory via params hash
      #
      #   @example
      #     ROM.container(:ldap, {})
      #
      #   @param [Hash]
      #
      # @overload initialize(params, options)
      #   Connects to a database via params and options
      #
      #   @example
      #     ROM.container(:ldap,
      #       {server:, username:, password:},
      #       {base: '', max_results: 100, timeout: 3}
      #     )
      #
      #   @param [Hash] passed to ROM::LDAP::Connection#new
      #
      #   @param options [Hash] default server options
      #
      #   @option options [Integer] :time Directory timeout in seconds
      #
      #   @option options [Integer] :size Directory result limit
      #
      # @return [LDAP::Gateway]
      #
      # @api public
      def initialize(server = EMPTY_HASH, options = EMPTY_HASH)
        @server  = server
        @options = options
        @logger  = options.fetch(:logger) { ::Logger.new(STDOUT) }
        @conn    = nil

        super()
      end

      # Used by attribute_inferrer
      #
      # @param filter [String]
      #
      # @return [Array<ROM::LDAP::Directory::Entity>]
      #
      # @api public
      def [](filter)
        directory.attributes(filter) || EMPTY_ARRAY
      end

      # Directory attributes identifiers and descriptions
      #
      # @return [Array<String>]
      #
      # @api public
      def attribute_types
        directory.attribute_types
      end

      # Disconnect from the gateway's directory
      #
      # @api public
      def disconnect
        directory.disconnect
      end

      # Return dataset with the given name
      #
      # @param filter [String] a filtered dataset
      #
      # @return [Dataset]
      #
      # @api public
      def dataset(filter)
        Dataset.new(directory, filter, base: options[:base])
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
        directory.type
      end

      alias directory_type database_type

      def connection
        if connected?
          @conn
        else
          @conn = Connection.new(
            server:           server[:server],
            connect_timeout:  options[:timeout],
            read_timeout:     options[:timeout],
            write_timeout:    options[:timeout],
            close_on_error:   false
            # on_connect: proc {}
            # proxy_server:
          )

          @conn.use_logger(@logger)
          bind! unless server[:username].nil?
          @conn
        end
      end

      private

      # Wrapper for Connection and Logger
      #
      # @return [Directory] ldap server object
      #
      # @api private
      def directory
        @dir ||= Directory.new(connection, options).load_rootdse!
      end

      def disconnect
        connection.close
      end

      def connected?
        !@conn.nil? && @conn.alive?
      end

      def bind!
        connection.bind(username: server[:username], password: server[:password])
      end
    end
  end
end
