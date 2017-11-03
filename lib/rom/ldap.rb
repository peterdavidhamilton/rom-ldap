require 'rom/core'

require 'rom/ldap/version'
require 'rom/ldap/errors'

require 'rom/ldap/ber'
require 'rom/ldap/ber/refinements'

require 'rom/ldap/pdu'

require 'rom/ldap/constants'
require 'rom/ldap/connection'

# require 'rom/configuration_dsl'

require 'rom/ldap/plugins'
require 'rom/ldap/struct'
require 'rom/ldap/relation'
require 'rom/ldap/associations'
require 'rom/ldap/gateway'
require 'rom/ldap/commands'
require 'rom/ldap/extensions'

ROM.register_adapter :ldap, ROM::LDAP
