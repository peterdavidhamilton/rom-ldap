require 'net/ldap'
require 'rom'
require 'rom/ldap/gateway'
require 'rom/ldap/relation'
require 'rom/ldap/associations'
require 'rom/ldap/commands'

ROM.register_adapter :ldap, ROM::Ldap
