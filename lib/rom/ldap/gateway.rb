require 'logger'
require 'rom/gateway'
require 'rom/ldap/directory'
require 'rom/ldap/dataset'
require 'rom/ldap/cache'

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
      #       {base: '', size: 100, timeout: 3}
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
      # @see https://github.com/ruby-ldap/ruby-net-ldap/blob/master/lib/net/ldap.rb
      #
      # @api public
      def initialize(server = EMPTY_HASH, options = EMPTY_HASH)
        @server  = server
        @conn    = nil
        @options = options
        @logger  = options.fetch(:logger) { ::Logger.new(STDOUT) }

        super()
      end

      attr_reader :server
      attr_reader :options

      # Used by attribute_inferrer
      #
      # @param filter [String,Net::LDAP::Filter]
      #
      # @return [Array<Net::LDAP::Entry>]
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
        # connection.connect unless connection.alive?

        Dataset.new(directory, filter)

        # rescue *ERROR_MAP.keys => e
        #   raise ERROR_MAP.fetch(e.class, Error), e
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

      private

      # Wrapper for Connection and Logger
      #
      # @return [Directory] ldap server object
      #
      # @api private
      def directory
        @directory ||= Directory.new(connection, options)
      end

      def connection
        if connected?
          @conn
        else
          @conn = Connection.new(
            server:           server[:server],
            connect_timeout:  options[:timeout],
            read_timeout:     options[:timeout],
            write_timeout:    options[:timeout]
            # on_connect: proc {}
            # proxy_server:
          )
          pdu = bind! unless server[:username].nil?
          (pdu && pdu.success?) ? @conn : pdu

          @conn
        end
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
