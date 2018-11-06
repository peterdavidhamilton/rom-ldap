require 'logger'
require 'rom/gateway'
require 'rom/ldap/directory'
require 'rom/ldap/dataset'

# @note Refinements add Hash#slice when <2.5
using ::Compatibility

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

      # @!attribute [r] dir_opts
      #   @return [Hash] Options passed to directory
      attr_reader :dir_opts

      # @!attribute [r] options
      #   @return [Hash] Options passed to gateway
      attr_reader :options

      # Initialize an LDAP gateway
      #
      # Gateways are typically initialized via ROM::Configuration object
      #
      # @overload initialize(options)
      #   Connects to a directory via options
      #
      #   @example
      #     ROM.container(:ldap, {})
      #
      #   @example
      #     ROM.container(:ldap, options)
      #
      #   @option options :servers [Array<String>] Defaults to ['127.0.0.1:389']
      #
      #   @option options :timeout [Integer] Connection timeout in seconds.
      #
      #   @option options :base [String] Connection timeout in seconds.
      #
      #   @option options :max_results [Integer] Directory result limit.
      #
      #   @option options :logger [Object] Defaults to silenced Logger.
      #
      # @return [LDAP::Gateway]
      #
      def initialize(options = EMPTY_HASH)
        @options  = options
        @dir_opts = options.slice(:base, :timeout, :max_results, :logger)
        @logger   = options.fetch(:logger) { ::Logger.new(IO::NULL) }

        super()
      end

      # Used by attribute_inferrer
      #
      # @param filter [String]
      #
      # @return [Array<Directory::Entry>]
      #
      # @api public
      #
      def [](filter)
        directory.attributes(filter) || EMPTY_ARRAY
      end

      # Directory attributes identifiers and descriptions.
      #
      # @return [Array<String>]
      #
      # @api public
      #
      def attribute_types
        directory.attribute_types
      end

      # An enumerable object for chainable queries.
      #
      # @param filter [String] an ldap compatible filter string
      #
      # @return [Dataset] dataset with the given filter
      #
      # @api public
      #
      def dataset(filter)
        Dataset.new(directory: directory, filter: filter, base: options[:base])
      end

      # @param logger [Logger]
      #
      # @api public
      #
      def use_logger(logger)
        @logger = logger
      end

      # Underlying directory type
      #
      # @return [Symbol]
      #
      # @api public
      #
      def directory_type
        directory.type
      end

      # Create or return existing Connection instance and bind if username
      #
      # @return [Connection]
      #
      # @api public
      #
      def connection
        if connected?
          @connection
        else
          @connection = connect!
          @connection.use_logger(@logger)
          bind! unless options[:username].nil?
          @connection
        end
      end


      #
      # @return [Array<String>] Collection of LDAP servers.
      #
      # @api public
      #
      def servers
        options.fetch(:servers, %w'127.0.0.1:389')
      end

      # The Directory class receives the Connection and is passed to Dataset.
      #
      # @return [Directory] ldap server object
      #
      # @api public
      #
      def directory
        @directory ||= Directory.new(connection, dir_opts)
      end

      private

      # Initialise a new connection.
      #
      # @return [Connection] Subclass of Net::TCPClient
      #
      # @api private
      #
      def connect!
        Connection.new(
          servers:          servers,
          connect_timeout:  options[:timeout],
          read_timeout:     options[:timeout],
          write_timeout:    options[:timeout],
          close_on_error:   false
        )
      rescue *ERROR_MAP.keys => e
        raise ERROR_MAP.fetch(e.class, Error),
          "Connection failed: #{servers.join(',')}"
      end

      # Disconnect from the server.
      #
      # @return [?]
      #
      # @api private
      #
      def disconnect
        connection.close
        # @conn = nil
        # @dir = nil
      end


      # Check if connection instance exists and is connected.
      #
      # @return [Boolean]
      #
      # @api private
      #
      def connected?
        !@connection.nil? && @connection.alive?
      end


      # @api private
      def bind!
        connection.bind(options.slice(:username, :password))
      end
    end
  end
end
