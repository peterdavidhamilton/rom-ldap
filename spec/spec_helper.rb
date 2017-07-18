require 'bundler/setup'
Bundler.setup

require 'pry'
require 'minitest/spec'
require 'rom-ldap'
require 'pathname'

SPEC_ROOT = Pathname(__FILE__).dirname

Dir[SPEC_ROOT.join('support/*.rb')].each(&method(:require))
Dir[SPEC_ROOT.join('shared/*.rb')].each(&method(:require))
