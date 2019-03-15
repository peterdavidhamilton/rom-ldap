module ROM
  module LDAP

    # @see ROM::LDAP::Gateway
    #
    # @see ROM::LDAP::Schema::Inferrer
    #
    CONNECTION_FAILURES = [
      EOFError,
      Errno::ECONNABORTED,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      Errno::EIO,
      Errno::ENETDOWN,
      Errno::ENETRESET,
      Errno::EPIPE,
      Errno::ETIMEDOUT,
      IOError
    ]


    #
    ConfigError                   = Class.new(StandardError)
    #
    ConnectionError               = Class.new(StandardError)
    #
    BindError                     = Class.new(StandardError)
    SecureBindError               = Class.new(StandardError)
    OperationError                = Class.new(StandardError)
    PasswordError                 = Class.new(StandardError)
    UnknownAttributeError         = Class.new(StandardError)
    ResponseMissingError          = Class.new(StandardError)
    ResponseMissingOrInvalidError = Class.new(StandardError)
    ResponseTypeInvalidError      = Class.new(StandardError)

  end
end
