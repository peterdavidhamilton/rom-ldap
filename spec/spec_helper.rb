require 'bundler'
Bundler.setup

if RUBY_ENGINE == 'ruby' && ENV['COVERAGE'] == 'true'
  require 'yaml'
  rubies = YAML.load(File.read(File.join(__dir__, '..', '.travis.yml')))['rvm']
  latest_mri = rubies.select { |v| v =~ /\A\d+\.\d+.\d+\z/ }.max

  if RUBY_VERSION == latest_mri
    require 'simplecov'
    SimpleCov.start do
      add_filter '/spec/'
    end
  end
end


begin
  require 'pry-byebug'
rescue LoadError
end if ENV['PRY']

require 'rom-ldap'

require 'pathname'
SPEC_ROOT = root = Pathname(__FILE__).dirname
TMP_PATH  = root.join('../tmp')

require 'dry/core/deprecations'
Dry::Core::Deprecations.set_logger!(root.join('../log/deprecations.log'))


RSpec.configure do |config|
  config.disable_monkey_patching!
  # config.warnings = warning_api_available

  config.before(:suite) do
    tmp_test_dir = TMP_PATH.join('test')
    FileUtils.rm_r(tmp_test_dir) if File.exist?(tmp_test_dir)
    FileUtils.mkdir_p(tmp_test_dir)
  end

  config.before do
    module Test
    end
  end

  config.after do
    Object.send(:remove_const, :Test)
  end

  Dir[root.join('support/*.rb')].each(&method(:require))
  Dir[root.join('shared/*.rb')].each(&method(:require))

  config.include(Helpers, helpers: true)
  # config.include ENVHelper
end

