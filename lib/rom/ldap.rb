require 'rom/core'

require 'net/ldap'
# require 'rom/ldap/net_ldap'

# TODO: uncouple from net/ldap using 'connection'
require 'rom/ldap/connection'

require 'rom/ldap/version'
require 'rom/ldap/errors'
require 'rom/ldap/constants'

require 'rom/configuration_dsl'

require 'rom/ldap/plugins'
require 'rom/ldap/relation'
require 'rom/ldap/associations'
require 'rom/ldap/gateway'
require 'rom/ldap/commands'
require 'rom/ldap/extensions'

ROM.register_adapter :ldap, ROM::LDAP
