# encoding: utf-8

require 'bundler/setup'
Bundler.setup

require 'minitest/spec'
require 'rom-ldap'

# if RUBY_ENGINE == 'rbx'
#   require "codeclimate-test-reporter"
#   CodeClimate::TestReporter.start
# end

require 'pry'

require 'pathname'
SPEC_ROOT = root = Pathname(__FILE__).dirname

Dir[root.join('shared/*.rb').to_s].each { |f| require f }
