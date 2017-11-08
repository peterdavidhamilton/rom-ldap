require 'rom/initializer'
require 'rom/support/memoizable'
require 'timeout'

require 'rom/ldap/directory/root'
require 'rom/ldap/directory/sub_schema'
require 'rom/ldap/directory/capabilities'
require 'rom/ldap/directory/operations'

module ROM
  module LDAP
    class Directory
      extend Initializer
      extend Notifications::Listener

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

      subscribe('configuration.directory', adapter: :ldap) do |event|
        binding.pry
      end

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
        schema_attribute_types.flat_map(&method(:parse_attribute_type)).reject(&:nil?).sort_by(&:first)
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
        return unless attribute_name = type[/NAME '(\S+)'/, 1]
        {
          # name:        Functions.to_method_name(attribute_name),
          name:        BER.formatter(attribute_name),
          # name:        BER::Entity.rename(attribute_name),
          description: type[/DESC '(.+)' [A-Z]+/, 1],
          oid:         type[/SYNTAX (\S+)/, 1].tr("'", ''),
          matcher:     type[/EQUALITY (\S+)/, 1],
          substr:      type[/SUBSTR (\S+)/, 1],
          ordering:    type[/ORDERING (\S+)/, 1],
          single:      !type.scan(/SINGLE-VALUE/).empty?,
          modifiable:  !type.scan(/NO-USER-MODIFICATION/).empty?,
          usage:       type[/USAGE (\S+)/, 1],
          source:      type[/X-SCHEMA '(\S+)'/, 1]
        }
      end

      memoize :root, :sub_schema, :attribute_types
    end
  end
end
