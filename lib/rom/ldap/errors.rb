require 'rom/ldap/error'

module ROM
  module LDAP

    # @example
    #
    #   rescue *ERROR_MAP.keys => e
    #     raise ERROR_MAP.fetch(e.class, Error), e

    ConnectionError = Class.new(StandardError)
    FilterError     = Class.new(StandardError)

    ERROR_MAP = {
      Errno::ECONNREFUSED                       => ConnectionError,
      Net::LDAP::AlreadyOpenedError             => ConnectionError,
      Net::LDAP::ConnectionRefusedError         => ConnectionError,
      Net::LDAP::Error                          => ConnectionError,
      Net::LDAP::BindingInformationInvalidError => ConnectionError,
      Net::LDAP::ResponseMissingOrInvalidError  => FilterError,
    }.freeze
  end
end
