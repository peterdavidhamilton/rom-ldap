# encoding: utf-8
# frozen_string_literal: true

require 'net/ldap'
require 'rom'
require 'rom/ldap/relation'
require 'rom/ldap/gateway'
require 'rom/ldap/commands'

ROM.register_adapter :ldap, ROM::Ldap
