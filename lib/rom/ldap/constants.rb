require 'psych'
require 'dry/core/constants'

module ROM
  module LDAP
    include Dry::Core::Constants

    WILDCARD   = '*'.freeze
    OP_ATTRS   = '+'.freeze
    NEW_LINE   = "\n".freeze
    EMPTY_BASE = EMPTY_STRING

    # Including :create_timestamp, :modify_timestamp, :entry_uuid
    ALL_ATTRIBUTES = [WILDCARD, OP_ATTRS].freeze

    CONSTRUCTORS = {
      con_and: '&', # intersection
      con_or:  '|', # union
      con_not: '!', # negation
    }.freeze

    # NB: Order of values effects regexp
    OPERATORS = {
      op_prx: '~=',
      op_ext: ':=',
      op_gte: '>=',
      op_lte: '<=',
      op_eql: '='
    }.freeze

    VALUES = {
      :wildcard => WILDCARD,
      true      => 'TRUE',
      false     => 'FALSE'
    }.freeze

    #
    # DSL dataset methods
    #
    ESCAPES = {
      "\0" => '00', # NUL      = %x00     null character
      '*'  => '2A', # ASTERISK = %x2A     asterisk ("*")
      '('  => '28', # LPARENS  = %x28     left parenthesis ("(")
      ')'  => '29', # RPARENS  = %x29     right parenthesis (")")
      '\\' => '5C', # ESC      = %x5C     esc (or backslash) ("\")
    }.freeze

    ESCAPE_REGEX = Regexp.new('[' + ESCAPES.keys.map { |e| Regexp.escape(e) }.join + ']')

    #
    # Expression Encoder
    #
    EXTENSIBLE_REGEX = /^([-;\w]*)(:dn)?(:(\w+|[.\w]+))?$/
    UNESCAPE_REGEX   = /\\([a-fA-F\d]{2})/

    #
    # Regexp
    #
    WS_REGEX      = /\s*/
    OPEN_REGEX    = /\s*\(\s*/
    CLOSE_REGEX   = /\s*\)\s*/
    AND_REGEX     = /\s*\&\s*/
    OR_REGEX      = /\s*\|\s*/
    NOT_REGEX     = /\s*\!\s*/
    ATTR_REGEX    = /[-\w:.]*[\w]/
    VAL_REGEX     = /(?:[-\[\]{}\w*.+\/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]|[^\x00-\x7F]|\\[a-fA-F\d]{2})+/u
    OP_REGEX      = Regexp.union(*OPERATORS.values)
    BRANCH_REGEX  = Regexp.union(OR_REGEX, AND_REGEX)

    #
    # Type Builder
    #
    STRING_MATCHERS = %w[
      caseExactIA5Match
      caseExactMatch
      caseIgnoreIA5Match
      caseIgnoreListMatch
      caseIgnoreMatch
      distinguishedNameMatch
      numericStringMatch
      numericStringOrderingMatch
      numericStringSubstringsMatch
      objectIdentifierMatch
      octetStringMatch
      protocolInformationMatch
      telephoneNumberMatch
      telephoneNumberSubstringsMatch
      uuidMatch
    ].freeze

    INTEGER_MATCHERS = %w[
      integerMatch
      integerOrderingMatch
    ].freeze

    TIME_MATCHERS = %w[
      csnMatch
      generalizedTimeMatch
      generalizedTimeOrderingMatch
    ].freeze

    BOOLEAN_MATCHERS = %w[
      booleanMatch
    ].freeze

    #
    # Schema files
    #
    SCHEMA = %w[
      core
      cosine
      inetorgperson
      misc
      nis
      openldap
    ].freeze
    # apache
    # apachemeta
    # system

    #
    # Search Scope
    #
    SCOPE_BASE_OBJECT  = 0
    SCOPE_SINGLE_LEVEL = 1
    SCOPE_SUBTREE      = 2

    SCOPES = [SCOPE_BASE_OBJECT, SCOPE_SINGLE_LEVEL, SCOPE_SUBTREE].freeze

    #
    # Alias Dereferencing
    #
    DEREF_NEVER  = 0
    DEREF_SEARCH = 1
    DEREF_FIND   = 2
    DEREF_ALWAYS = 3

    DEREF_ALL = [DEREF_NEVER, DEREF_SEARCH, DEREF_FIND, DEREF_ALWAYS].freeze

    #
    # Operation Tokens
    #
    MODIFY_OPERATIONS = { add: 0, delete: 1, replace: 2 }.freeze

    #
    # Root DSE (DSA-specific entry) - attributes for all implementations
    #
    ROOT_DSE_ATTRS = %w[
      altServer
      changelog
      currentTime
      dataversion
      dnsHostName
      domainControllerFunctionality
      domainFunctionality
      firstChangeNumber
      forestFunctionality
      isGlobalCatalogReady
      isSynchronized
      lastChangeNumber
      lastusn
      namingContexts
      netscapemdsuffix
      operatingSystemVersion
      rootDomainNamingContext
      subschemaSubentry
      supportedAuthPasswordSchemes
      supportedCapabilities
      supportedControl
      supportedExtension
      supportedFeatures
      supportedLdapVersion
      supportedSASLMechanisms
      vendorName
      vendorVersion
    ].freeze

    #
    # Root DSE
    # supportedSASLMechanisms
    #
    SASL_TYPES = %w[
      CRAM-MD5
      DIGEST-MD5
      EXTERNAL
      GSS-SPNEGO
      GSSAPI
      NTLM
      SIMPLE
      SRP
    ].freeze

    #
    # OID Controls ---------------------------------------------
    #

    MATCHED_VALUES_CONTROL     = '1.2.826.0.1.3344810.2.3'.freeze

    #
    # Active Directory
    #
    MICROSOFT_OID_PREFIX       = '1.2.840.113556'.freeze
    PAGED_RESULTS              = '1.2.840.113556.1.4.319'.freeze
    SHOW_DELETED               = '1.2.840.113556.1.4.417'.freeze
    SORT_REQUEST               = '1.2.840.113556.1.4.473'.freeze
    SORT_RESPONSE              = '1.2.840.113556.1.4.474'.freeze
    CROSSDOM_MOVE_TARGET       = '1.2.840.113556.1.4.521'.freeze
    SEARCH_NOTIFICATION        = '1.2.840.113556.1.4.528'.freeze
    LAZY_COMMIT                = '1.2.840.113556.1.4.619'.freeze
    SD_FLAGS                   = '1.2.840.113556.1.4.801'.freeze
    MATCHING_RULE_BIT_AND      = '1.2.840.113556.1.4.803'.freeze
    MATCHING_RULE_BIT_OR       = '1.2.840.113556.1.4.804'.freeze
    DELETE_TREE                = '1.2.840.113556.1.4.805'.freeze
    DIRECTORY_SYNC             = '1.2.840.113556.1.4.841'.freeze
    VERIFY_NAME                = '1.2.840.113556.1.4.1338'.freeze
    DOMAIN_SCOPE               = '1.2.840.113556.1.4.1339'.freeze
    SEARCH_OPTIONS             = '1.2.840.113556.1.4.1340'.freeze
    PERMISSIVE_MODIFY          = '1.2.840.113556.1.4.1413'.freeze
    FAST_CONCURRENT_BIND       = '1.2.840.113556.1.4.1781'.freeze
    MATCHING_RULE_IN_CHAIN     = '1.2.840.113556.1.4.1941'.freeze

    CANCEL_OPERATION           = '1.3.6.1.1.8'.freeze
    ASSERTION_CONTROL          = '1.3.6.1.1.12'.freeze
    PRE_READ_CONTROL           = '1.3.6.1.1.13.1'.freeze
    POST_READ_CONTROL          = '1.3.6.1.1.13.2'.freeze
    MODIFY_INCREMENT           = '1.3.6.1.1.14'.freeze

    PASSWORD_POLICY_REQUEST    = '1.3.6.1.4.1.42.2.27.8.5.1'.freeze

    APPLE_OID_PREFIX           = '1.3.6.1.4.1.63'.freeze

    NOTICE_OF_DISCONNECTION    = '1.3.6.1.4.1.1466.20036'.freeze
    START_TLS                  = '1.3.6.1.4.1.1466.20037'.freeze
    DYNAMIC_REFRESH            = '1.3.6.1.4.1.1466.101.119.1'.freeze

    ALL_OPERATIONAL_ATTRIBUTES = '1.3.6.1.4.1.4203.1.5.1'.freeze
    OC_AD_LISTS                = '1.3.6.1.4.1.4203.1.5.2'.freeze
    TRUE_FALSE_FILTERS         = '1.3.6.1.4.1.4203.1.5.3'.freeze
    LANGUAGE_TAG_OPTIONS       = '1.3.6.1.4.1.4203.1.5.4'.freeze
    LANGUAGE_RANGE_OPTIONS     = '1.3.6.1.4.1.4203.1.5.5'.freeze
    SYNC_REQUEST_CONTROL       = '1.3.6.1.4.1.4203.1.9.1.1'.freeze
    SYNC_STATE_CONTROL         = '1.3.6.1.4.1.4203.1.9.1.2'.freeze
    SYNC_DONE_CONTROL          = '1.3.6.1.4.1.4203.1.9.1.3'.freeze
    SYNC_INFO_MESSAGE          = '1.3.6.1.4.1.4203.1.9.1.4'.freeze
    SUBENTRIES                 = '1.3.6.1.4.1.4203.1.10.1'.freeze
    PASSWORD_MODIFY            = '1.3.6.1.4.1.4203.1.11.1'.freeze
    WHO_AM_I                   = '1.3.6.1.4.1.4203.1.11.3'.freeze

    CASCADE_CONTROL            = '1.3.6.1.4.1.18060.0.0.1'.freeze
    GRACEFUL_SHUTDOWN_REQUEST  = '1.3.6.1.4.1.18060.0.1.3'.freeze
    GRACEFUL_DISCONNECT        = '1.3.6.1.4.1.18060.0.1.5'.freeze

    MANAGE_DSA_IT              = '2.16.840.1.113730.3.4.2'.freeze
    PERSISTENT_SEARCH          = '2.16.840.1.113730.3.4.3'.freeze
    ENTRY_CHANGE_NOTIFICATION  = '2.16.840.1.113730.3.4.7'.freeze
    VIRTUAL_LIST_VIEW_REQUEST  = '2.16.840.1.113730.3.4.9'.freeze
    VIRTUAL_LIST_VIEW_RESPONSE = '2.16.840.1.113730.3.4.10'.freeze
    PROXIED_AUTHORIZATION_V2   = '2.16.840.1.113730.3.4.18'.freeze
  end
end
