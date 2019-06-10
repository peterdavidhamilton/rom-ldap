require 'rom/ldap/controls'
require 'rom/ldap/scopes'
require 'rom/ldap/aliases'
require 'rom/ldap/matchers'
require 'rom/ldap/type_map'
require 'rom/ldap/responses'

module ROM
  module LDAP

    # Matches an ldap protocol url ldap://host:port/base
    #
    # @return [Regexp]
    LDAPURI_REGEX = %r"^ldaps?://[\w/\.]+:?\d*/?(\w+=\w+,?)*.*$"

    # Any word character or hyphen, equals
    #
    # @return [Regexp]
    DN_REGEX = /(([-\w]+=[-\w]+)*,?)/

    # Something in parentheses
    #
    # @return [Regexp]
    FILTER_REGEX = /^\s*\(.*\)\s*$/

    # @return [String]
    NEW_LINE  = "\n".freeze

    # @return [String]
    WILDCARD  = '*'.freeze

    # @return [Array<String>]
    #
    # @see Relation#add_operational
    #
    OP_ATTRS  = %w'+'.freeze

    # @return [Array<String>]
    ALL_ATTRS = [WILDCARD, *OP_ATTRS].freeze

    # @return [Array<String>]
    #
    # @example [Schema]
    #   use :timestamps,
    #     attributes: %i(create_timestamp modify_timestamp),
    #     type: ROM::LDAP::Types::Time
    #
    #
    # @see Relation#add_timestamps
    #
    TIMESTAMPS = %w[createTimestamp modifyTimestamp].freeze

    # @return [String]
    #
    DEFAULT_FILTER = '(objectClass=*)'.freeze


    # Time conversion
    #
    # @return [Integer]
    #
    # @see Functions.to_time
    TEN_MILLION = 10_000_000.freeze

    # @return [Integer]
    #
    # @see Functions.to_time
    SINCE_1601  = 11_644_473_600.freeze

    # Internal abstraction of LDAP string search filter constructors.
    #
    # @see https://www.rfc-editor.org/rfc/rfc4515.txt String Search Filter Definition
    #
    # @return [Hash]
    #
    CONSTRUCTORS = {
        con_and: '&',   # AND / AMPERSAND   / %x26
        con_or:  '|',   # OR  / VERTBAR     / %x7C
        con_not: '!',   # NOT / EXCLAMATION / %x21
      }.freeze

    # Internal abstraction of LDAP string search filter operators.
    #
    # @return [Hash]
    #
    # @see https://www.rfc-editor.org/rfc/rfc4515.txt String Search Filter Definition
    #
    #   equal          = EQUALS
    #   approx         = TILDE EQUALS
    #   greaterorequal = RANGLE EQUALS
    #   lessorequal    = LANGLE EQUALS
    #   extensible     = ( attr [dnattrs]
    #                        [matchingrule] COLON EQUALS assertionvalue )
    #                    / ( [dnattrs]
    #                         matchingrule COLON EQUALS assertionvalue )
    #
    OPERATORS = {
        op_eql: '=',    # Equal to
        op_prx: '~=',   # Approximately equal to
        op_gte: '>=',   # Lexicographically greater than or equal to
        op_lte: '<=',   # Lexicographically less than or equal to
        op_ext: ':='    # Bitwise comparison of numeric values
      }.freeze


    # @return [Array]
    #
    ABSTRACTS = [*OPERATORS.keys, *CONSTRUCTORS.keys].freeze

    # Symbolic abstraction of LDIF booleans and wildcard matcher
    #
    # @return [Hash]
    #
    VALUES_MAP = {
        :wildcard => WILDCARD, #  ANY / ASTERISK / %x2A
        true      => 'TRUE',
        false     => 'FALSE'
      }.freeze

    #
    # DSL dataset methods
    #
    # @see RFC4515 value encoding rule.
    #
    # @return [Hash]
    #
    ESCAPES = {
        "\0" => '00',   #   NUL      / %x00
        '*'  => '2A',   #   ASTERISK / %x2A
        '('  => '28',   #   LPARENS  / %x28
        ')'  => '29',   #   RPARENS  / %x29
        '\\' => '5C',   #   ESC      / %x5C
      }.freeze

    #
    # Expression Encoder
    # (1)type (2)dn (4)rule
    #
    # <attribute name>:<matching rule OID>:=<value>
    # (&(objectCategory=group)(groupType:1.2.840.113556.1.4.803:=2147483648))
    #
    # @return [Regexp]
    #
    EXTENSIBLE_REGEX = /^([-;\w]*)(:dn)?(:(\w+|[.\w]+))?$/.freeze

    # ESC and HEX values
    #
    # The value encoding rule ensures that the entire filter string is a valid
    # UTF-8 string and provides that the octets that represent theses ESCAPES
    # are represented as a backslash followed by the two hexadecimal digits
    # representing the value of the encoded octet.
    #
    UNESCAPE_REGEX   = /\\([a-f\d]{2})/i.freeze

    #
    ESCAPE_REGEX = Regexp.new('[' + ESCAPES.keys.map { |e| Regexp.escape(e) }.join + ']')


  end
end
