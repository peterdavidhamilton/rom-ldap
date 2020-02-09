# frozen_string_literal: true

require 'rom/ldap/oid'
require 'rom/ldap/scope'
require 'rom/ldap/alias'
require 'rom/ldap/matchers'
require 'rom/ldap/type_map'
require 'rom/ldap/responses'

module ROM
  module LDAP
    # Matches an ldap(s) url
    #
    # @return [Regexp]
    LDAPURI_REGEX = Regexp.union(
      ::URI::DEFAULT_PARSER.make_regexp('ldap'),
      ::URI::DEFAULT_PARSER.make_regexp('ldaps')
    ).freeze

    # Any word character or hyphen, equals
    #
    # @return [Regexp]
    DN_REGEX = /(([-\w]+=[-\w]+)*,?)/.freeze

    # Something in parentheses
    #
    # @return [Regexp]
    FILTER_REGEX = /^\s*\(.*\)\s*$/.freeze

    # @return [String]
    NEW_LINE = "\n"

    # @return [String]
    WILDCARD = '*'

    # @return [Array<String>]
    OP_ATTRS = %w[+].freeze

    # @return [Array<String>]
    ALL_ATTRS = [WILDCARD, *OP_ATTRS].freeze

    # @return [String]
    DEFAULT_PK = 'entrydn'

    # @return [Array<String>]
    #
    # @example [Schema]
    #   use :timestamps,
    #     attributes: %i(create_timestamp modify_timestamp),
    #     type: ROM::LDAP::Types::Time
    #
    #
    # @see Relation#operational
    #
    TIMESTAMPS = %w[createTimestamp modifyTimestamp].freeze

    # @return [String]
    #
    DEFAULT_FILTER = '(objectClass=*)'

    # Time conversion
    #
    # @return [Integer]
    #
    # @see Functions.to_time
    TEN_MILLION = 10_000_000

    # @return [Integer]
    #
    # @see Functions.to_time
    SINCE_1601 = 11_644_473_600

    # Internal abstraction of LDAP string search filter constructors.
    #
    # @see https://www.rfc-editor.org/rfc/rfc4515.txt String Search Filter Definition
    #
    # @return [Hash]
    #
    CONSTRUCTORS = {
      con_and: '&', # AND / AMPERSAND   / %x26
      con_or:  '|',   # OR  / VERTBAR     / %x7C
      con_not: '!'    # NOT / EXCLAMATION / %x21
    }.freeze

    CONSTRUCTOR_REGEX = Regexp.union(/\s*\|\s*/, /\s*\&\s*/).freeze

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
      op_bineq: '=', # Binary comparison
      op_eql: '=',    # Equal to
      op_prx: '~=',   # Approximately equal to
      op_gte: '>=',   # Lexicographically greater than or equal to
      op_lte: '<=',   # Lexicographically less than or equal to
      op_ext: ':='    # Bitwise comparison of numeric values
    }.freeze

    OPERATOR_REGEX = Regexp.union(*OPERATORS.values).freeze

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
      '\\' => '5C'    #   ESC      / %x5C
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
    UNESCAPE_REGEX = /\\([a-f\d]{2})/i.freeze

    # @return [Regexp]
    #
    ESCAPE_REGEX = Regexp.new('[' + ESCAPES.keys.map { |e| Regexp.escape(e) }.join + ']').freeze

    # @return [Regexp]
    #
    VAL_REGEX = %r"(?:[-\[\]{}\w*.+/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]|[^\x00-\x7F]|\x5C(?:[\x20-\x23]|[\x2B\x2C]|[\x3B-\x3E]|\x5C)|\\[a-fA-F\d]{2})+"u.freeze

    # Local file path
    #
    # @return [Regexp]
    #
    BIN_FILE_REGEX = %r{^file://(.*)}.freeze

    # $1 = attribute
    # $3 = value
    #
    LDIF_LINE_REGEX = /^([^:]+):([\:]?)[\s]*<?(.*)$/.freeze
  end
end
