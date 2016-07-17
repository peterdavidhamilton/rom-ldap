# encoding: utf-8
# frozen_string_literal: true

require 'net/ldap'
require 'rom'

ROM.register_adapter :ldap, ROM::Ldap
