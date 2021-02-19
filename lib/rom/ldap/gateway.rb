# frozen_string_literal: true

require 'logger'
require 'rom/gateway'
require 'rom/ldap/directory'
require 'rom/ldap/dataset'

module ROM
  module LDAP
    # @abstract
    #   Responsible for initialising connection, binding to server.
    #   Wrapping the connection in the directory and then dataset abstractions,
    #   and passing them to the relations.
    #
    class Gateway < ROM::Gateway

      adapter :ldap

      # @!attribute [r] directory
      #   @return [String]
      attr_reader :directory

      # @!attribute [r] logger
      #   @return [Object] configured gateway logger
      attr_reader :logger

      # Initialize an LDAP gateway
      #
      # Gateways are typically initialized via ROM::Configuration object
      #
      # @overload initialize(uri, options)
      #   Connects to a directory via options
      #
      #   @example
      #     ROM.container(:ldap, uri, {})
      #
      #   @param uri [String] 'ldap://127.0.0.1:389' or nil
      #
      #   @option options :username [String] BINDDN Directory admin username.
      #
      #   @option options :password [String] BINDDN Directory admin password.
      #
      #   @option options :base [String] BASE Directory search base.
      #
      #   @option options :timeout [Integer] Connection timeout in seconds.
      #
      #   @option options :logger [Object] Defaults to $stdout
      #
      # @return [LDAP::Gateway]
      #
      def initialize(uri = nil, **options)
        @directory = Directory.new(uri, options)
        @logger = options.fetch(:logger) { ::Logger.new(STDOUT) }

        options.fetch(:extensions, EMPTY_ARRAY).each do |ext|
          next unless LDAP.available_extension?(ext)

          LDAP.load_extensions(ext)
        end

        super()
      end

      # Used by attribute_inferrer to query attributes.
      #
      # @param filter [String]
      #
      # @return [Array<Directory::Entry>]
      #
      # @api public
      #
      def [](filter)
        directory.query_attributes(filter)
      end
      alias_method :call, :[]

      # Directory attributes identifiers and descriptions.
      #
      # @see Schema::Inferrer
      # @see Schema::TypeBuilder
      #
      # @return [Array<String>]
      #
      # @api public
      #
      def attribute_types
        directory.attribute_types
      end

      # Check for presence of entries under new filter.
      #
      # @param name [String] An ldap compatible filter string.
      #
      # @return [Boolean]
      #
      # @api public
      #
      def dataset?(name)
        dataset(name).any?
      end

      # An enumerable object for chainable queries.
      #
      # @param name [String] An ldap compatible filter string.
      #   Used as the param to schema block in relation classes.
      #
      # @return [Dataset] Scoped by name filter.
      #
      # @api public
      #
      def dataset(name)
        Dataset.new(name: name, directory: directory)
      end

      # @param logger [Logger]
      #
      # @api public
      #
      def use_logger(logger)
        directory.logger = @logger = logger
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

      # Disconnect from the server.
      #
      # @return [?]
      #
      # @api public
      #
      def disconnect
        directory.disconnect
      end

    end
  end
end
