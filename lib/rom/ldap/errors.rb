require 'rom/ldap/error'

module ROM
  module LDAP

    # @example
    #
    #   rescue *ERROR_MAP.keys => e
    #     raise ERROR_MAP.fetch(e.class, Error), e

    ConnectionError = Class.new(StandardError)
    FilterError     = Class.new(StandardError)
    ConfigError     = Class.new(StandardError)

    ERROR_MAP = {

      ArgumentError                             => ConfigError,
      Net::LDAP::AuthMethodUnsupportedError     => ConfigError,
      Net::LDAP::EncMethodUnsupportedError      => ConfigError,
      Net::LDAP::EncryptionUnsupportedError     => ConfigError,
      Net::LDAP::NoSearchBaseError              => ConfigError,
      Net::LDAP::SearchScopeInvalidError        => ConfigError,

      Errno::ECONNREFUSED                       => ConnectionError,
      Net::LDAP::ConnectionRefusedError         => ConnectionError,
      Net::LDAP::Error                          => ConnectionError,
      Net::LDAP::AlreadyOpenedError             => ConnectionError,
      Net::LDAP::BindingInformationInvalidError => ConnectionError,

      Net::LDAP::ResponseMissingOrInvalidError  => FilterError,
      Net::LDAP::FilterTypeUnknownError         => FilterError,
      Net::LDAP::FilterSyntaxInvalidError       => FilterError,
      Net::LDAP::SearchFilterError              => FilterError,
      Net::LDAP::SearchFilterTypeUnknownError   => FilterError,

      # Net::LDAP::BadAttributeError
      # Net::LDAP::BERInvalidError
      # Net::LDAP::EmptyDNError
      # Net::LDAP::EntryOverflowError
      # Net::LDAP::HashTypeUnsupportedError
      # Net::LDAP::NoBindResultError
      # Net::LDAP::NoOpenSSLError
      # Net::LDAP::NoStartTLSResultError
      # Net::LDAP::OperatorError
      # Net::LDAP::ResponseMissingOrInvalidError
      # Net::LDAP::ResponseTypeInvalidError
      # Net::LDAP::SASLChallengeOverflowError
      # Net::LDAP::SearchSizeInvalidError
      # Net::LDAP::SocketError
      # Net::LDAP::StartTLSError
      # Net::LDAP::SubstringFilterError
    }.freeze
  end
end
