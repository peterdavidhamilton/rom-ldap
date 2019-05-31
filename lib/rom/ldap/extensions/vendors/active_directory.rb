module ROM
  module LDAP
    #
    # Microsoft Active Directory Extension
    #
    module ActiveDirectory

      #
      # @note
      #   Use the AD Forest configuration container as a search base.
      #
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

      # @return [String]
      #
      def vendor_name
        'Microsoft'
      end

      # @return [String]
      #
      def vendor_version
        VERSION_NAMES[domain_functionality]
      end

      # @return [Integer]
      #
      def controller_functionality
        root.first('domainControllerFunctionality').to_i
      end

      # @return [Integer]
      #
      def forest_functionality
        root.first('forestFunctionality').to_i
      end

      # @return [Integer]
      #
      def domain_functionality
        root.first('domainFunctionality').to_i
      end

      # LDAP server internal clock
      #
      # @return [Time]
      #
      def directory_time
        Functions[:to_time][root.first('currentTime')]
      end

      # @return [Array<String>]
      #
      def supported_capabilities
        root['supportedCapabilities'].sort
      end

    end

    # Directory.include ActiveDirectory
    Directory.send(:include, ActiveDirectory)


    # CONTROLS = CONTROLS.dup.merge!(
    #   extended_dn:    '1.2.840.113556.1.4.529',   # Extended DN control (Stateless)
    #   get_stats:      '1.2.840.113556.1.4.970',   # Get stats control (Stateless)
    #   verify_name:    '1.2.840.113556.1.4.1338',  # Verify name control (Stateless)
    #   domain_scope:   '1.2.840.113556.1.4.1339',  # LDAP_SERVER_DOMAIN_SCOPE_OID
    #   unknown:        '1.2.840.113556.1.4.1340',
    #   # unknown:        '1.2.840.113556.1.4.1341',
    #   # unknown:        '1.2.840.113556.1.4.1413',
    #   # unknown:        '1.2.840.113556.1.4.1504',
    #   # unknown:        '1.2.840.113556.1.4.1852',
    #   # unknown:        '1.2.840.113556.1.4.1907',
    #   # unknown:        '1.2.840.113556.1.4.1948',
    #   # unknown:        '1.2.840.113556.1.4.1974',
    #   # unknown:        '1.2.840.113556.1.4.2026',
    #   # unknown:        '1.2.840.113556.1.4.2064',
    #   # unknown:        '1.2.840.113556.1.4.2065',
    #   # unknown:        '1.2.840.113556.1.4.2066',
    #   # unknown:        '1.2.840.113556.1.4.2090',
    #   # unknown:        '1.2.840.113556.1.4.2204',
    #   # unknown:        '1.2.840.113556.1.4.2205',
    #   # unknown:        '1.2.840.113556.1.4.2206',
    #   # unknown:        '1.2.840.113556.1.4.2211',
    #   # unknown:        '1.2.840.113556.1.4.2239',
    #   # unknown:        '1.2.840.113556.1.4.2255',
    #   # unknown:        '1.2.840.113556.1.4.2256'
    # ).freeze
  end
end



