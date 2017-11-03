require 'rom/ldap/error'

module ROM
  module LDAP

    ConnectionError               = Class.new(StandardError)
    FilterError                   = Class.new(StandardError)
    ConfigError                   = Class.new(StandardError)
    ResponseMissingOrInvalidError = Class.new(StandardError)
    ResponseMissingError          = Class.new(StandardError)
    NoBindResultError             = Class.new(StandardError)
    ResponseTypeInvalidError      = Class.new(StandardError)

  end
end
