require 'rom/ldap/error'

module ROM
  module LDAP
    #
    ConfigError                   = Class.new(StandardError)
    ConnectionError               = Class.new(StandardError)
    FilterError                   = Class.new(StandardError)
    NoBindResultError             = Class.new(StandardError)
    OperationError                = Class.new(StandardError)
    PasswordError                 = Class.new(StandardError)
    ResponseMissingError          = Class.new(StandardError)
    ResponseMissingOrInvalidError = Class.new(StandardError)
    ResponseTypeInvalidError      = Class.new(StandardError)

    ERROR_MAP = {
      Errno::ECONNREFUSED               => ConnectionError,
      Net::TCPClient::ConnectionFailure => ConnectionError,
      Net::TCPClient::ConnectionTimeout => ConnectionError,
      Net::TCPClient::ReadTimeout       => ConnectionError
    }.freeze

    ERRORS = {
      missing_or_invalid: [ResponseMissingOrInvalidError, 'response missing or invalid'],
      no_bind_result:     [NoBindResultError, 'no bind result']
    }.freeze
  end
end
