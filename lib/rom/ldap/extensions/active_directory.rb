module ROM
  module LDAP
    # Microsoft Active Directory
    module ActiveDirectory
      #
      # NB: Use the AD Forest configuration container as a search base.
      # @see https://msdn.microsoft.com/en-us/library/ms684291(v=vs.85).aspx
      #
      # RootDSE domainFunctionality
      # RootDSE domainControllerFunctionality
      # RootDSE forestFunctionality
      #
      VERSION_NAMES = {
        0 => 'Windows Server 2000 (5.0)',
        1 => 'Windows Server 2003 (5.2)',
        2 => 'Windows Server 2003 R2 (5.2)',
        3 => 'Windows Server 2008 (6.0)',
        4 => 'Windows Server 2008 R2 (6.1)',
        5 => 'Windows Server 2012 (6.2)',
        6 => 'Windows Server 2012 R2 (6.3)',
        7 => 'Windows Server 2016 (10.0)',
        8 => 'Windows Server Latest Version (?)'
      }.freeze

      #
      # RootDSE supportedLDAPPolicies
      #
      POLICIES = %w[
        InitRecvTimeout
        MaxBatchReturnMessages
        MaxConnections
        MaxConnIdleTime
        MaxDatagramRecv
        MaxNotificationPerConn
        MaxPageSize
        MaxPercentDirSyncRequests
        MaxPoolThreads
        MaxQueryDuration
        MaxReceiveBuffer
        MaxResultSetSize
        MaxResultSetsPerConn
        MaxTempTableSize
        MaxValRange
        MaxValRangeTransitive
        MinResultSets
        SystemMemoryLimitPercent
        ThreadMemoryLimit
      ].freeze

      #
      # Integer Codes
      #
      ACCOUNT_DISABLE                = 2.freeze
      DOMAIN_CONTROLLER              = 532480.freeze
      DONT_EXPIRE_PASSWORD           = 65536.freeze
      DONT_REQ_PREAUTH               = 4194304.freeze
      ENCRYPTED_TEXT_PWD_ALLOWED     = 128.freeze
      GROUP_TYPE_GLOBAL_GROUP        = 2.freeze
      GROUP_TYPE_LOCAL_GROUP         = 4.freeze
      GROUP_TYPE_SECURITY_ENABLED    = 2147483648.freeze
      GROUP_TYPE_UNIVERSAL_GROUP     = 8.freeze
      HOMEDIR_REQUIRED               = 8.freeze
      INTERDOMAIN_TRUST_ACCOUNT      = 2048.freeze
      LOCKOUT                        = 16.freeze
      MNS_LOGON_ACCOUNT              = 131072.freeze
      NORMAL_ACCOUNT                 = 512.freeze
      NOT_DELEGATED                  = 1048576.freeze
      PARTIAL_SECRETS_ACCOUNT        = 67108864.freeze
      PASSWORD_CANT_CHANGE           = 64.freeze # @see http://msdn2.microsoft.com/en-us/library/aa746398.aspx
      PASSWORD_NOT_REQUIRED          = 32.freeze
      PASSWORD_EXPIRED               = 8388608.freeze
      SCRIPT                         = 1.freeze
      SERVER_TRUST_ACCOUNT           = 8192.freeze
      SMARTCARD_REQUIRED             = 262144.freeze # When this flag is set, it forces the user to log on by using a smart card.
      TEMP_DUPLICATE_ACCOUNT         = 256.freeze
      TRUSTED_FOR_DELEGATION         = 524288.freeze
      TRUSTED_TO_AUTH_FOR_DELEGATION = 16777216.freeze
      USE_DES_KEY_ONLY               = 2097152.freeze
      WORKSTATION_TRUST_ACCOUNT      = 4096.freeze

      #
      # Groups and Objects
      #
      COMPUTERS                 = '(objectCategory=Computer)'.freeze
      CONTACTS                  = '(objectCategory=contact)'.freeze
      DOMAIN_CONTROLLERS        = '(&(objectCategory=Computer)(userAccountControl:1.2.840.113556.1.4.803:=8192))'.freeze
      EMPTY_GROUPS              = '(&(objectClass=group)(!member=*))'.freeze
      GLOBAL_CATALOGS           = '(&(objectCategory=nTDSDSA)(options:1.2.840.113556.1.4.803:=1))'.freeze
      OBJECTS_CANT_DELETE       = '(systemFlags:1.2.840.113556.1.4.803:=-2147483648)'.freeze
      OBJECTS_CANT_RENAME       = '(systemFlags:1.2.840.113556.1.4.803:=134217728)'.freeze
      SECURITY_GROUPS           = '(groupType:1.2.840.113556.1.4.803:=2147483648)'.freeze
      UNIVERSAL_GROUPS          = '(groupType:1.2.840.113556.1.4.803:=8)'.freeze
      UNIVERSAL_SECURITY_GROUPS = '(groupType=2147483656)'.freeze

      # nested_group_search = '(&(objectCategory=Person)(sAMAccountName=*)(memberOf:1.2.840.113556.1.4.1941:=cn=CaptainPlanet,ou=users,dc=company,dc=com))'.freeze

      #
      # Users and Accounts
      #
      USERS                        = '(sAMAccountType=805306368)'.freeze
      USERS_WITH_EMAIL             = '(&(sAMAccountType=805306368)(mailNickname=*))'.freeze

      DISABLED_ACCOUNT             = '(userAccountControl:1.2.840.113556.1.4.803:=2)'.freeze
      ENABLED_ACCOUNT              = '(!userAccountControl:1.2.840.113556.1.4.803:=2)'.freeze

      PASSWORDLESS_ACCOUNT         = '(&(sAMAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=32))'.freeze
      PASSWORD_NEVER_EXPIRES       = '(userAccountControl:1.2.840.113556.1.4.803:=65536)'.freeze

      EXCHANGE_SERVERS             = '(&(objectClass=msExchExchangeServer)(!(objectClass=msExchExchangeServerPolicy)))'.freeze
      EXCHANGE_RECIPIENTS          = '(mailNickname=*)'.freeze
      EXCHANGE_RECIPIENTS_HIDDEN   = '(&(msExchHideFromAddressLists=TRUE)(!objectClass=publicFolder))'.freeze
      EXCHANGE_RECIPIENTS_WITH_FAX = '(proxyAddresses=FAX:*)'.freeze

    end
  end
end
