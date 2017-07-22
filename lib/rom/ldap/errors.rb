require 'rom/ldap/error'

module ROM
  module LDAP

    # @example
    #
    #   rescue *ERROR_MAP.keys => e
    #     raise ERROR_MAP.fetch(e.class, Error), e

    DirectoryConnectionError = Class.new(StandardError)
    DirectoryFilterError     = Class.new(StandardError)

    ERROR_MAP = {
      Errno::ECONNREFUSED => DirectoryConnectionError,
      Net::LDAP::ConnectionRefusedError => DirectoryConnectionError,
      Net::LDAP::Error => DirectoryConnectionError,
      Net::LDAP::ResponseMissingOrInvalidError => DirectoryFilterError
    }.freeze
  end
end
