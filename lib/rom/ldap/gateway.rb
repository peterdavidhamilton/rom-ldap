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
      #     ROM.container(:ldap, {}, size: 100, time: 3)
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
      def initialize(directory = EMPTY_HASH, options = EMPTY_HASH)
        @directory = directory
        @conn      = nil
        @options   = options
        @logger    = options.fetch(:logger) { ::Logger.new(STDOUT) }

        super()
      end

      attr_reader :directory
      attr_reader :options

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


      # TODO: wrap with shot-term caching ie: 60 seconds, set by class attribute
      # CACHE = Moneta.build do
      #   use :Expires
      #   use :Transformer, key: [:marshal, :base64], value: :marshal
      #   adapter :Memory
      # end
      # CACHE.fetch(options) do


      # Return dataset with the given name
      #
      # @param filter [String] a filtered dataset
      #
      # @return [Dataset]
      #
      # @api public
      def dataset(filter)
        connection.connect unless connection.alive?

        Dataset.new(api, filter)

        rescue *ERROR_MAP.keys => e
          raise ERROR_MAP.fetch(e.class, Error), e
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
        @api ||= Dataset::API.new(connection, logger)
      end

      def connection
        if connected?
          @conn
        else
          @conn = Connection.new(
            server:           directory[:server],
            connect_timeout:  options[:time],
            read_timeout:     options[:time],
            write_timeout:    options[:time]
            # on_connect: proc {}
            # proxy_server:
          )

          @conn.directory_options = options # base, size, time

          pdu = bind! if directory[:username] # simple only
          pdu.success? ? @conn : pdu
          @conn
        end
      end

      def connected?
        !@conn.nil? && @conn.alive?
      end

      def bind!
        connection.bind(
          username: directory[:username],
          password: directory[:password]
        )
      end
    end
  end
end
