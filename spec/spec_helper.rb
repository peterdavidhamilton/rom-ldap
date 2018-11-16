require 'bundler/setup'

begin
  require 'pry-byebug'
rescue LoadError
end

require 'rom-ldap'

require 'dry-types'
module Types
  include Dry::Types.module
end

require 'pathname'
SPEC_ROOT = root = Pathname(__FILE__).dirname
TMP_PATH  = root.join('../tmp')

require 'dry/core/deprecations'
Dry::Core::Deprecations.set_logger!(root.join('../log/deprecations.log'))

RSpec.configure do |config|
  config.disable_monkey_patching!

  Dir[root.join('support/*.rb')].each(&method(:require))
  Dir[root.join('shared/*.rb')].each(&method(:require))
end

