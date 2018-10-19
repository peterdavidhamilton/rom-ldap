require 'rom/ldap/error'

module ROM
  module LDAP
    #                                                        # USAGE
    ConfigError                   = Class.new(StandardError) # WIP
    ConnectionError               = Class.new(StandardError) # mapped below
    FilterError                   = Class.new(StandardError) # filter builder
    NoBindResultError             = Class.new(StandardError) # authenticate operation
    OperationError                = Class.new(StandardError) # directory
    ResponseMissingError          = Class.new(StandardError) # update operation
    ResponseMissingOrInvalidError = Class.new(StandardError) # all operations
    ResponseTypeInvalidError      = Class.new(StandardError) # search operation

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
