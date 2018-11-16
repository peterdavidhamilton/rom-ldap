require 'rom/initializer'
require 'dry/core/class_attributes'

# wip
require 'dry/monitor/notifications'

require 'rom/ldap/functions'
require 'rom/ldap/directory/root'
require 'rom/ldap/directory/capabilities'
require 'rom/ldap/directory/operations'
require 'rom/ldap/directory/password'

module ROM
  module LDAP
    class Directory
      extend Initializer
      extend Dry::Core::ClassAttributes

      # notifications = Dry::Monitor::Notifications.new(:directory)

      # @see options[:base]
      defines :default_base
      default_base   EMPTY_BASE

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

      # Builds list of attributes and writes to class variable.
      #
      # @return [Array<Hash>] Parsed array of all directory attributes.
      #
      # @example
      #   [{
      #            :name => "cn",
      #        :original => "cn",
      #     :description => "RFC2256: common name(s) for which the entity is known by",
      #             :oid => "1.3.6.1.4.1.1466.115.121.1.15",
      #         :matcher => "caseIgnoreMatch",
      #          :substr => "caseIgnoreSubstringsMatch",
      #        :ordering => nil,
      #          :single => false,
      #      :modifiable => false,
      #           :usage => "userApplications",
      #          :source => "system"
      #   }]
      #
      # @api public
      def attribute_types
        self.class.attributes ||= build_attribute_list
      end

      private

      # Output changes depending on Directory::Entry.formatter
      #
      # @api private
      def build_attribute_list
        schema_attribute_types
          .flat_map(&method(:parse_attribute_type))
          .flatten.reject(&:nil?)
          .sort_by(&:first).freeze
      end

      # Build hash from attribute definition.
      #
      # @example
      #   parse_attribute_type("...")
      #     #=> { name: :uidnumber, description: '', single: true)
      #
      # @param type [String]
      #
      # @return [Hash]
      #
      # @see TypeBuilder
      #
      # @api private
      def parse_attribute_type(type)
        attribute_names =
          if type[/NAME '(\S+)'/, 1]
            type[/NAME '(\S+)'/, 1]
          elsif type[/NAME \( '(\S+)' '(\S+)' \)/]
            [Regexp.last_match(1), Regexp.last_match(2)]
          end

    # Attribute Type Description Format - RFC4512
    #
    # https://docs.oracle.com/cd/E19476-01/821-0509/attribute-type-description-format.html
    #
    # oid:     type[/^\(\s*([\d\.]*)/, 1],
    # rfc4512: type
    # https://ping.force.com/Support/PingIdentityArticle?id=kA340000000PMwQCAW
    #
    #
    # X-ALLOWED-VALUE — Provides an explicit set of values that are the only values that will be allowed for the associated attribute.
    # X-VALUE-REGEX — Provides one or more regular expressions that describe acceptable values for the associated attribute. Values will only be allowed if they match at least one of the regular expressions.
    # X-MIN-VALUE-LENGTH — Specifies the minimum number of characters that values of the associated attribute are permitted to have.
    # X-MAX-VALUE-LENGTH — Specifies the maximum number of characters that values of the associated attribute are permitted to have.
    # X-MIN-INT-VALUE — Specifies the minimum integer value that may be assigned to the associated attribute.
    # X-MAX-INT-VALUE — Specifies the maximum integer value that may be assigned to the associated attribute.
    # X-MIN-VALUE-COUNT — Specifies the minimum number of values that the attribute is allowed to have in any entry.
    # X-MAX-VALUE-COUNT — Specifies the maximum number of values that the attribute is allowed to have in any entry.

        Array(attribute_names).map do |name|
          {
            name:        Entry.rename(name), # canonical
            original:    name,               # source
            description: type[/DESC '(.+)' [A-Z]+/, 1],
            oid:         type[/SYNTAX (\S+)/, 1].to_s.tr("'", ''),
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

    end
  end
end
