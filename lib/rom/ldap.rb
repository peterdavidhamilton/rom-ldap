require 'rom/core'
require 'net/ldap'

require 'rom/ldap/version'
require 'rom/ldap/errors'

require 'rom/configuration_dsl'

require 'rom/ldap/plugins'
require 'rom/ldap/relation'
require 'rom/ldap/associations'
require 'rom/ldap/gateway'
require 'rom/ldap/commands'
# require 'rom/sql/migration'
require 'rom/ldap/extensions'

ROM.register_adapter :ldap, ROM::LDAP
