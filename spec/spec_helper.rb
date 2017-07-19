require 'bundler/setup'
Bundler.setup

require 'pry'
require 'rom-ldap'

require 'minitest/spec'
class Module
  include Minitest::Spec::DSL
end

require 'rom-factory'
Faker::Config.random = Random.new(42)
Faker::Config.locale = :en

require 'pathname'
SPEC_ROOT = Pathname(__FILE__).dirname

Dir[SPEC_ROOT.join('support/*.rb')].each(&method(:require))
Dir[SPEC_ROOT.join('shared/*.rb')].each(&method(:require))

