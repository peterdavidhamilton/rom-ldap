source 'https://rubygems.org'

gemspec

gem 'ldap-ber', git: 'ssh://git@gitlab.com/peterdavidhamilton/ldap-ber', branch: 'develop'

gem 'rom', git: 'ssh://git@github.com/rom-rb/rom', branch: 'master' do
  gem 'rom-core'
  gem 'rom-mapper'
  gem 'rom-changeset'
  gem 'rom-repository'
end

group :development do
  gem 'awesome_print'
  gem 'rouge'
  gem 'pry', platforms: %i[jruby rbx]
  gem 'pry-byebug', platforms: :mri
end

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'msgpack', '~> 1.2.4', require: false # @see spec/unit/relation/export_spec.rb
  # gem 'builder', require: false # @see spec/unit/relation/export_spec.rb
  gem 'libxml-ruby', require: false # @see spec/unit/relation/export_spec.rb
  gem 'faker', github: 'stympy/faker', branch: 'master', require: false
  gem 'rom-factory', github: 'rom-rb/rom-factory', branch: 'master', require: false
  gem 'rubocop', '~> 0.58', require: false
  gem 'simplecov', require: false
end

group :benchmark do
  gem 'benchmark-ips', github: 'evanphx/benchmark-ips', branch: 'master'
  gem 'net-ldap'
end
