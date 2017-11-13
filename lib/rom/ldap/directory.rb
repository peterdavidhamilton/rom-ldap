require 'rom/initializer'
require 'dry/core/class_attributes'
require 'rom/support/memoizable'
require 'timeout'

# require 'dry-monitor'

require 'rom/ldap/directory/root'
require 'rom/ldap/directory/sub_schema'
require 'rom/ldap/directory/capabilities'
require 'rom/ldap/directory/operations'

module ROM
  module LDAP
    class Directory
      extend Initializer
      # extend Notifications::Listener

      extend Dry::Core::ClassAttributes

      defines :ldap_version
      defines :default_base
      defines :default_filter

      ldap_version   3
      default_base   EMPTY_STRING
      default_filter '(objectClass=*)'.freeze

      include Memoizable
      include Root
      include SubSchema
      include Operations
      include Capabilities

      param :connection

      option :base
      option :timeout, default: proc { 30 }
      option :size,    default: proc { 1_000_000 }
      option :logger,  default: proc { ::Logger.new(STDOUT) }


      # Dry::Monitor::Notifications.new(:app)

      # subscribe('configuration.directory', adapter: :ldap) do |event|
      #   binding.pry
      # end

      # @return [Array<String>]
      #
      # @example
      #   [ 'Apple', '510.30' ]
      #   [ 'Apache Software Foundation', '2.0.0-M24' ]
      #
      # @api public
      def vendor
        [vendor_name, vendor_version]
      end

      # Directory attributes identifiers and descriptions
      #
      # @return [Array<Hash>]
      #
      # @api public
      def attribute_types
        types = schema_attribute_types.flat_map(&method(:parse_attribute_type))
        types.flatten.reject(&:nil?).sort_by(&:first)
      end

      private

      def log(caller = nil, message = nil, level = :info)
        logger.send(level, "#{self.class}##{caller} #{message}")

        if result.failure?
          logger.error("#{self.class}##{caller} #{result.error_message}")
        end
        if result.message
          logger.debug("#{self.class}##{caller} #{result.message}")
        end
      end

      # Build hash from attribute definition
      #   used by TypeBuilder
      #
      # @example
      #   parse_attribute_type("...")
      #     #=> { name: :uidnumber, description: '', single: true)
      #
      # @param type [String]
      #
      # @return [Hash]
      #
      # @api private
      def parse_attribute_type(type)
        attribute_names = if type[/NAME '(\S+)'/, 1]
                            type[/NAME '(\S+)'/, 1]
                          elsif type[/NAME \( '(\S+)' '(\S+)' \)/]
                            [Regexp.last_match(1), Regexp.last_match(2)]
                          end

        Array(attribute_names).map do |name|
          {
            name:        Entity.rename(name),
            original:    name,
            description: type[/DESC '(.+)' [A-Z]+/, 1],
            oid:         type[/SYNTAX (\S+)/, 1].tr("'", ''),
            matcher:     type[/EQUALITY (\S+)/, 1],
            substr:      type[/SUBSTR (\S+)/, 1],
            ordering:    type[/ORDERING (\S+)/, 1],
            single:      type.scan(/SINGLE-VALUE/).any?,
            modifiable:  type.scan(/NO-USER-MODIFICATION/).any?,
            usage:       type[/USAGE (\S+)/, 1],
            source:      type[/X-SCHEMA '(\S+)'/, 1]
          }
        end
      end

      memoize :root, :sub_schema, :attribute_types
    end
  end
end
