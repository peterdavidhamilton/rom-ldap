require 'dry/core/constants'

module ROM
  module LDAP
    include Dry::Core::Constants

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
    SCOPE_BASE_OBJECT  = 0.freeze
    SCOPE_SINGLE_LEVEL = 1.freeze
    SCOPE_SUBTREE      = 2.freeze
    EMPTY_BASE         = EMPTY_STRING

    #
    # Aliase Dereferencing
    #
    DEREF_NEVER  = 0.freeze
    DEREF_SEARCH = 1.freeze
    DEREF_FIND   = 2.freeze
    DEREF_ALWAYS = 3.freeze

    #
    # Root DSE - attributes for all implementations
    #
    ROOT_DSE_ATTRS = %w[
      altServer
      currentTime
      dataversion
      dnsHostName
      domainControllerFunctionality
      domainFunctionality
      forestFunctionality
      isGlobalCatalogReady
      isSynchronized
      lastusn
      namingContexts
      netscapemdsuffix
      operatingSystemVersion
      rootDomainNamingContext
      subschemaSubentry
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
    # OID Controls
    #
    MATCHED_VALUES_CONTROL     = '1.2.826.0.1.3344810.2.3'.freeze


    MICROSOFT_OID_PREFIX       = '1.2.840.113556'.freeze
    PAGED_RESULTS              = '1.2.840.113556.1.4.319'.freeze
    SHOW_DELETED               = '1.2.840.113556.1.4.417'.freeze
    SORT_REQUEST               = '1.2.840.113556.1.4.473'.freeze
    SORT_RESPONSE              = '1.2.840.113556.1.4.474'.freeze
    SEARCH_NOTIFICATION        = '1.2.840.113556.1.4.528'.freeze
    MATCHING_RULE_BIT_AND      = '1.2.840.113556.1.4.803'.freeze
    MATCHING_RULE_BIT_OR       = '1.2.840.113556.1.4.804'.freeze
    DELETE_TREE                = '1.2.840.113556.1.4.805'.freeze
    DIRECTORY_SYNC             = '1.2.840.113556.1.4.841'.freeze
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
