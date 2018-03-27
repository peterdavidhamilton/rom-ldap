require 'logger'
require 'rom/gateway'
require 'rom/ldap/directory'
require 'rom/ldap/dataset'

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
      #   @return [Hash] Options passed to directory
      attr_reader :options

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
      #     ROM.container(:ldap, options)
      #
      #   @option options :uri [String] Server URI '127.0.0.1:10389'
      #
      #   @option options :timeout [Integer] Directory timeout in seconds
      #
      #   @option options :base [String] Directory timeout in seconds
      #
      #   @option options :max_results [Integer] Directory result limit
      #
      # @return [LDAP::Gateway]
      #
      # @api public
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

      # Return dataset with the given name
      #
      # @param filter [String] a filtered dataset
      #
      # @return [Dataset]
      #
      # @api public
      def dataset(filter)
        Dataset.new(directory: directory, filter: filter, base: options[:base])
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
      def directory_type
        directory.type
      end

      # Create or return existing Connection instance and bind if username
      #
      # @return [Connection]
      #
      # @api public
      def connection
        if connected?
          @conn
        else
          @conn = Connection.new(
            server:           options[:uri],
            connect_timeout:  options[:timeout],
            read_timeout:     options[:timeout],
            write_timeout:    options[:timeout],
            close_on_error:   false
            # on_connect: proc {}
            # proxy_server:
            # connect_retry_interval: 10.0,
            # connect_retry_count: 1.day.to_i
          )

          @conn.use_logger(@logger)
          bind! unless options[:username].nil?
          @conn
        end
      end

      # Wrapper for Connection and Logger.
      #
      # @return [Directory] ldap server object
      #
      # @api public
      def directory
        @dir ||= Directory.new(connection, dir_opts).load_rootdse!
      end

      private

      # Disconnect from the server
      #
      # @api public
      def disconnect
        connection.close
      end

      def connected?
        !@conn.nil? && @conn.alive?
      end

      def bind!
        connection.bind(options.slice(:username, :password))
      end
    end
  end
end
