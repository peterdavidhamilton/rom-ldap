require 'rom/initializer'
require 'dry/core/class_attributes'

# wip
require 'dry/monitor/notifications'

require 'rom/ldap/functions'
require 'rom/ldap/directory/root'
require 'rom/ldap/directory/capabilities'
require 'rom/ldap/directory/operations'
require 'rom/ldap/directory/password'

require 'rom/ldap/directory/attribute_parser'

module ROM
  module LDAP
    class Directory
      extend Initializer
      extend Dry::Core::ClassAttributes

      # notifications = Dry::Monitor::Notifications.new(:directory)

      # @see options[:base]
      defines :default_base
      default_base EMPTY_BASE

      # @see operations module directory#query
      defines :default_filter
      default_filter '(objectClass=*)'.freeze

      include Root
      include Operations
      include Capabilities

      param :connection, reader: :private

      option :base,        default: -> { self.class.default_base }
      option :timeout,     default: -> { 30 }
      option :max_results, default: -> { TEN_MILLION }
      option :logger,      default: -> { ::Logger.new(IO::NULL) }

      # @see Gateway#directory
      #
      # @require rom/ldap/extensions/{vendor}
      #
      # @return [ROM::LDAP::Directory]
      #
      def initialize(*)
        super

        LDAP.load_extensions(type) if LDAP.available_extension?(type)
      end

      # PDU object
      attr_reader :result

      # @return [String]
      #
      # @api public
      def inspect
        "#<#{self.class} servers=#{connection.servers} base='#{base}' ldap_versions=#{supported_versions} vendor='#{vendor_name}' release='#{vendor_version}' />"
      end



      # If fail_on_error => true, this should reopen the connection.
      #
      # @return [?]
      # @todo Document return value.
      # @api public
      def reconnect
        connection.connect
      end

      # Cache built attributes array as class variable.
      #   Allows specs to trigger rebuilding by deleting and allows functions access.
      #
      # @api public
      class << self
        attr_accessor :attributes
      end

      def attribute_types
        self.class.attributes ||= parse_attributes
      end

      private

      # Output changes depending on Directory::Entry.formatter
      #
      # @api private
      def parse_attributes
        schema_attribute_types
          .flat_map { |foo| AttributeParser.new(foo).call }
          .flatten.reject(&:nil?)
          .sort_by(&:first).freeze
      end

    end
  end
end
