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
    end
  end
end
