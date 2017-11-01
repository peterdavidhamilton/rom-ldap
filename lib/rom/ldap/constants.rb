require 'dry/core/constants'

module ROM
  module LDAP
    include Dry::Core::Constants

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





# Hex
# Decimal
# Description

# 0x00
# 0
# LDAP_SUCCESS: Indicates the requested client operation completed successfully.
# 0x01
# 1
# LDAP_OPERATIONS_ERROR: Indicates an internal error. The server is unable to respond with a more specific error and is also unable to properly respond to a request. It does not indicate that the client has sent an erroneous message.
# 0x02
# 2
# LDAP_PROTOCOL_ERROR: Indicates that the server has received an invalid or malformed request from the client.
# 0x03
# 3
# LDAP_TIMELIMIT_EXCEEDED: Indicates the operation's time limit specified by either the client or the server has been exceeded. On search operations, incomplete results are returned.
# 0x04
# 4
# LDAP_SIZELIMIT_EXCEEDED: Indicates in a search operation, the size limit specified by the client or the server has been exceeded. Incomplete results are returned.
# 0x05
# 5
# LDAP_COMPARE_FALSE: Does not indicate an error condition. Indicates that the results of a compare operation are false.
# 0x06
# 6
# LDAP_COMPARE_TRUE: Does not indicate an error condition. Indicates that the results of a compare operation are true.
# 0x07
# 7
# LDAP_AUTH_METHOD_NOT_SUPPORTED: Indicates during a bind operation the client requested an authentication method not supported by the LDAP server.
# 0x08
# 8
# LDAP_STRONG_AUTH_REQUIRED: Indicates one of the following:
# In bind requests, the LDAP server accepts only strong authentication.
# In a client request, the client requested an operation such as delete that requires strong authentication.
# In an unsolicited notice of disconnection, the LDAP server discovers the security protecting the communication between the client and server has unexpectedly failed or been compromised.
# 0x09
# 9
# Reserved.
# 0x0A
# 10
# LDAP_REFERRAL: Does not indicate an error condition. In LDAPv3, indicates that the server does not hold the target entry of the request, but that the servers in the referral field may.
# 0x0B
# 11
# LDAP_ADMINLIMIT_EXCEEDED: Indicates an LDAP server limit set by an administrative authority has been exceeded.
# 0x0C
# 12
# LDAP_UNAVAILABLE_CRITICAL_EXTENSION: Indicates the LDAP server was unable to satisfy a request because one or more critical extensions were not available. Either the server does not support the control or the control is not appropriate for the operation type.
# 0x0D
# 13
# LDAP_CONFIDENTIALITY_REQUIRED: Indicates the session is not protected by a protocol such as Transport Layer Security (TLS), which provides session confidentiality.
# 0x0E
# 14
# LDAP_SASL_BIND_IN_PROGRESS: Does not indicate an error condition, but indicates the server is ready for the next step in the process. The client must send the server the same SASL mechanism to continue the process.
# 0x0F
# 15
# Not used.
# 0x10
# 16
# LDAP_NO_SUCH_ATTRIBUTE: Indicates the attribute specified in the modify or compare operation does not exist in the entry.
# 0x11
# 17
# LDAP_UNDEFINED_TYPE: Indicates the attribute specified in the modify or add operation does not exist in the LDAP server's schema.
# 0x12
# 18
# LDAP_INAPPROPRIATE_MATCHING: Indicates the matching rule specified in the search filter does not match a rule defined for the attribute's syntax.
# 0x13
# 19
# LDAP_CONSTRAINT_VIOLATION: Indicates the attribute value specified in a modify, add, or modify DN operation violates constraints placed on the attribute. The constraint can be one of size or content (string only, no binary).
# 0x14
# 20
# LDAP_TYPE_OR_VALUE_EXISTS: Indicates the attribute value specified in a modify or add operation already exists as a value for that attribute.
# 0x15
# 21
# LDAP_INVALID_SYNTAX: Indicates the attribute value specified in an add, compare, or modify operation is an unrecognized or invalid syntax for the attribute.
# 22-31
# Not used.
# 0x20
# 32
# LDAP_NO_SUCH_OBJECT: Indicates the target object cannot be found. This code is not returned on following operations:
# Search operations that find the search base but cannot find any entries that match the search filter.
# Bind operations.
# 0x21
# 33
# LDAP_ALIAS_PROBLEM: Indicates an error occurred when an alias was dereferenced.
# 0x22
# 34
# LDAP_INVALID_DN_SYNTAX: Indicates the syntax of the DN is incorrect. (If the DN syntax is correct, but the LDAP server's structure rules do not permit the operation, the server returns LDAP_UNWILLING_TO_PERFORM.)
# 0x23
# 35
# LDAP_IS_LEAF: Indicates the specified operation cannot be performed on a leaf entry. (This code is not currently in the LDAP specifications, but is reserved for this constant.)
# 0x24
# 36
# LDAP_ALIAS_DEREF_PROBLEM: Indicates during a search operation, either the client does not have access rights to read the aliased object's name or dereferencing is not allowed.
# 37-47
# Not used.
# 0x30
# 48
# LDAP_INAPPROPRIATE_AUTH: Indicates during a bind operation, the client is attempting to use an authentication method that the client cannot use correctly. For example, either of the following cause this error:
# The client returns simple credentials when strong credentials are required.
# The client returns a DN and a password for a simple bind when the entry does not have a password defined.
# 0x31
# 49
# LDAP_INVALID_CREDENTIALS: Indicates during a bind operation one of the following occurred:
# The client passed either an incorrect DN or password.
# The password is incorrect because it has expired, intruder detection has locked the account, or some other similar reason.
# 0x32
# 50
# LDAP_INSUFFICIENT_ACCESS: Indicates the caller does not have sufficient rights to perform the requested operation.
# 0x33
# 51
# LDAP_BUSY: Indicates the LDAP server is too busy to process the client request at this time but if the client waits and resubmits the request, the server may be able to process it then.
# 0x34
# 52
# LDAP_UNAVAILABLE: Indicates the LDAP server cannot process the client's bind request, usually because it is shutting down.
# 0x35
# 53
# LDAP_UNWILLING_TO_PERFORM: Indicates the LDAP server cannot process the request because of server-defined restrictions. This error is returned for the following reasons:
# The add entry request violates the server's structure rules.
# The modify attribute request specifies attributes that users cannot modify.
# Password restrictions prevent the action.
# Connection restrictions prevent the action.
# 0x36
# 54
# LDAP_LOOP_DETECT: Indicates the client discovered an alias or referral loop, and is thus unable to complete this request.
# 55-63
# Not used.
# 0x40
# 64
# LDAP_NAMING_VIOLATION: Indicates the add or modify DN operation violates the schema's structure rules. For example,
# The request places the entry subordinate to an alias.
# The request places the entry subordinate to a container that is forbidden by the containment rules.
# The RDN for the entry uses a forbidden attribute type.
# 0x41
# 65
# LDAP_OBJECT_CLASS_VIOLATION: Indicates the add, modify, or modify DN operation violates the object class rules for the entry. For example, the following types of request return this error:
# The add or modify operation tries to add an entry without a value for a required attribute.
# The add or modify operation tries to add an entry with a value for an attribute which the class definition does not contain.
# The modify operation tries to remove a required attribute without removing the auxiliary class that defines the attribute as required.
# 0x42
# 66
# LDAP_NOT_ALLOWED_ON_NONLEAF: Indicates the requested operation is permitted only on leaf entries. For example, the following types of requests return this error:
# The client requests a delete operation on a parent entry.
# The client request a modify DN operation on a parent entry.
# 0x43
# 67
# LDAP_NOT_ALLOWED_ON_RDN: Indicates the modify operation attempted to remove an attribute value that forms the entry's relative distinguished name.
# 0x44
# 68
# LDAP_ALREADY_EXISTS: Indicates the add operation attempted to add an entry that already exists, or that the modify operation attempted to rename an entry to the name of an entry that already exists.
# 0x45
# 69
# LDAP_NO_OBJECT_CLASS_MODS: Indicates the modify operation attempted to modify the structure rules of an object class.
# 0x46
# 70
# LDAP_RESULTS_TOO_LARGE: Reserved for CLDAP.
# 0x47
# 71
# LDAP_AFFECTS_MULTIPLE_DSAS: Indicates the modify DN operation moves the entry from one LDAP server to another and thus requires more than one LDAP server.
# 72-79
# Not used.
# 0x50
# 80
# LDAP_OTHER: Indicates an unknown error condition. This is the default value for NDS error codes which do not map to other LDAP error codes.
# 0x51
# 81
# LDAP_SERVER_DOWN: Indicates the LDAP client cannot establish a connection with, or lost the connection to, the LDAP server.
# 0x52
# 82
# LDAP_LOCAL_ERROR: Indicates an error occurred in the LDAP client.
# 0x53
# 83
# LDAP_ENCODING_ERROR: Indicates the LDAP client encountered an error when encoding the LDAP request to be sent to the server.
# 0x54
# 84
# LDAP_DECODING_ERROR: Indicates the LDAP client encountered an error when decoding the LDAP response received from the server.
# 0x55
# 85
# LDAP_TIMEOUT: Indicates the LDAP client timed out while waiting for a response from the server. The specified timeout period has been exceeded and the server has not responded.
# 0x56
# 86
# LDAP_AUTH_UNKNOWN: Indicates an unknown authentication method was specified.
# 0x57
# 87
# LDAP_FILTER_ERROR: Indicates an error occurred when specifying the search filter.
# 0x58
# 88
# LDAP_USER_CANCELLED: Indicates the user cancelled the LDAP operation
# 0x59
# 89
# LDAP_PARAM_ERROR: Indicates that an invalid parameter was specified.
# 0x5a
# 90
# LDAP_NO_MEMORY: Indicates that no memory is available. For example, when creating an LDAP request or an LDAP control).
# 0x5b
# 91
# LDAP_CONNECT_ERROR: Indicates the LDAP client cannot establish a connection, or has lost the connection, with the LDAP server.
# 0x5c
# 92
# LDAP_NOT_SUPPORTED: Indicates that the LDAP client is attempting to use functionality that is not supported. For example, the client identifies itself as an LDAPv2 client, and attempt to use functionality only available in LDAPv3.
# 0x5d
# 93
# LDAP_CONTROL_NOT_FOUND: Indicates a requested LDAP control was not found. This result code is set when the client parsing a server response for controls and not finding the requested controls
# 0x5e
# 94
# LDAP_NO_RESULTS_RETURNED: Indicates no results were returned from the server.
# 0x5f
# 95
# LDAP_MORE_RESULTS_TO_RETURN: Indicates there are more results in the chain of results. This result code is returned when additional result codes are available from the LDAP server.
# 0x60
# 96
# LDAP_CLIENT_LOOP: Indicates the LDAP client detected a loop, for example, when following referrals.
# 0x61
# 97
# LDAP_REFERRAL_LIMIT_EXCEEDED: Indicates that the referral hop limit was exceeded. This result code is if the client is referred to other servers more times than allowed by the referral hop limit.



  end
end
