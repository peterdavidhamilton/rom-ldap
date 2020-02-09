require 'bundler/setup'

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
end

ENV['TZ'] = 'UTC'

ENV['LDAPURI']    = nil
ENV['LDAPHOST']   = nil
ENV['LDAPPORT']   = nil
ENV['LDAPBASE']   = nil
ENV['LDAPBINDDN'] = nil
ENV['LDAPBINDPW'] = nil

begin
  require 'pry-byebug'
rescue LoadError
end

require 'rom-ldap'

require 'dry-types'
module Types
  include Dry.Types
end

require 'pathname'
SPEC_ROOT = root = Pathname(__FILE__).dirname
TMP_PATH  = root.join('../tmp')
HOSTS = YAML.load_file(root.join('fixtures/vendors.yml')).freeze

require 'dry/core/deprecations'
Dry::Core::Deprecations.set_logger!(root.join('../log/deprecations.log'))

RSpec.configure do |config|
  config.disable_monkey_patching!

  Dir[root.join('support/*.rb')].each(&method(:require))
  Dir[root.join('shared/*.rb')].each(&method(:require))
end
