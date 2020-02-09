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
    ].freeze

    # @see Client::Authentication#bind
    #
    BindError                     = Class.new(StandardError)

    # @see Client::Authentication#sasl_bind
    #
    SecureBindError               = Class.new(StandardError)

    # @see Directory::Operations#find, #by_dn, #add
    #
    DistinguishedNameError        = Class.new(StandardError)

    # @see Socket#connect
    #
    ConnectionError               = Class.new(StandardError)

    # @see Directory::Password#generate
    #
    PasswordError                 = Class.new(StandardError)
  end
end
