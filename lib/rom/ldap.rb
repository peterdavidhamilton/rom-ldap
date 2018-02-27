require 'rom/core'

require 'rom/refinements/hash'

require 'rom/ldap/version'
require 'rom/ldap/constants'
require 'rom/ldap/connection'
require 'rom/ldap/errors'

require 'rom/configuration_dsl'

require 'rom/ldap/plugins'
require 'rom/ldap/struct'
require 'rom/ldap/relation'
require 'rom/ldap/associations'
require 'rom/ldap/gateway'
require 'rom/ldap/commands'
require 'rom/ldap/extensions'

if defined?(Rails)
  ROM::LDAP.load_extensions(:active_support_notifications, :rails_log_subscriber)
end

ROM.register_adapter :ldap, ROM::LDAP
