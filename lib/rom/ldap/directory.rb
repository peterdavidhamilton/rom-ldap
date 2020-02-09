require 'rom/ldap/directory/env'
require 'rom/ldap/directory/entry'
require 'rom/ldap/directory/password'

require 'rom/ldap/directory/root'
require 'rom/ldap/directory/capabilities'
require 'rom/ldap/directory/operations'
require 'rom/ldap/directory/transactions'
require 'rom/ldap/directory/tokenization'


module ROM
  module LDAP
    # @abstract
    #   Builds LDAP directory abstraction over TCP connection instance.
    #   Includes vendor specific modules once initialised.
    #
    #
    class Directory

      attr_accessor :logger

      attr_reader :client
      attr_reader :env

      # Load vendor specific modules.
      #
      # @see rom/ldap/extensions/{vendor}
      # @see Gateway#directory
      #
      # @return [ROM::LDAP::Directory]
      #
      def initialize(uri, options)
        @env    = ENV.new(uri, options)

        @client = Client.new(@env.to_h, @env.auth, @env.ssl)

        @logger = options.fetch(:logger, Logger.new($stdout))

        require "rom/ldap/directory/vendors/#{type}"
        extend LDAP.const_get(Inflector.camelize(type))
      end

      include Root
      include Capabilities
      include Tokenization
      include Operations
      include Transactions

      # Expected method inside gateway.
      #
      # @return [TrueClass]
      #
      def disconnect
        client.close
        client.closed?
      end


      # Initial search base.
      #
      # @return [String] Defaults to "".
      #
      def base
        env.base || EMPTY_STRING
      end

      # Parsed attributes.
      # Output influenced by LDAP.formatter. Ordered alphabetically.
      #
      # @return [Array<Hash>]
      #
      def attribute_types
        @attribute_types ||= schema_attribute_types.map(&method(:to_attribute)).flatten.freeze
      end

      # Look up canonical name for a formatted attribute.
      #
      # @see Dataset#order_by and Dataset#select
      #
      # @param attrs [Array<Symbol,String>] formatted attribute names.
      #
      # @return [Array<String>] camelCased canonical LDAP attributes.
      #
      def canonical_attributes(attrs)
        attrs.map do |formatted|
          attribute_by(:name, formatted).fetch(:canonical, formatted.to_s)
        end
      end

      # Query parsed attribute definition hashes by key.
      #
      # @example
      #   directory.attribute_by(:name, :jpeg_photo) => { name: :jpeg_photo, ...}
      #
      # @param key [Symbol]
      # @param value [Mixed]
      #
      # @return [Hash]
      #
      def attribute_by(key, value)
        attribute_types.find { |a| a[key].eql?(value) } || EMPTY_HASH
      end

      # Hash of attribute names converted => original
      #
      # @example { formatted_name: 'canonicalName' }
      #
      # @return [Hash]
      #
      def key_map
        attribute_types.map { |a| a.values_at(:name, :canonical) }.sort.to_h
      end

      # @return [String]
      #
      # @api public
      def inspect
        "#<#{self.class} uri='#{env.uri}' vendor='#{vendor_name}' version='#{vendor_version}' />"
      end

    end
  end
end
