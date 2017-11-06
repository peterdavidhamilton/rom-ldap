require 'rom/ldap/error'
require 'net/tcp_client/exceptions'

module ROM
  module LDAP

    # Not used anymore?
    FilterError                   = Class.new(StandardError)
    ConfigError                   = Class.new(StandardError)



    OperationError                = Class.new(StandardError)
    ConnectionError               = Class.new(StandardError)
    ResponseMissingOrInvalidError = Class.new(StandardError) # all operations
    ResponseMissingError          = Class.new(StandardError) # update operation
    NoBindResultError             = Class.new(StandardError) # authenticate operation
    ResponseTypeInvalidError      = Class.new(StandardError) # search operation

    ERROR_MAP = {
      Errno::ECONNREFUSED               => ConnectionError,
      Net::TCPClient::ConnectionFailure => ConnectionError,
      Net::TCPClient::ConnectionTimeout => ConnectionError,
      Net::TCPClient::ReadTimeout       => ConnectionError
    }.freeze

  end
end
