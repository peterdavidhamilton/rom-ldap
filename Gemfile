source 'https://rubygems.org'

gemspec

gem 'ldap-ber', git: "https://oauth2:#{ENV['GITLAB_TOKEN']}@gitlab.com/peterdavidhamilton/ldap-ber", branch: 'develop'

gem 'rom', github: 'rom-rb/rom' do
  gem 'rom-core'
  gem 'rom-mapper'
  gem 'rom-changeset'
  gem 'rom-repository'
end

group :development do
  gem 'awesome_print'
  gem 'dry-monitor'
  gem 'rouge'
  gem 'pry', platforms: %i[jruby rbx]
  gem 'pry-byebug', platforms: :mri
end

group :test do
  gem 'rspec'
  # gem 'codeclimate-test-reporter', require: false
  gem 'msgpack', '~> 1.2.4', require: false # @see spec/unit/relation/export_spec.rb
  gem 'libxml-ruby', require: false # @see spec/unit/relation/export_spec.rb
  gem 'faker', github: 'stympy/faker', branch: 'master', require: false
  gem 'rom-factory'
  gem 'rubocop', '~> 0.58', require: false
  gem 'rubocop-performance', require: false
  gem 'simplecov', require: false
end

group :benchmark do
  gem 'benchmark-ips', github: 'evanphx/benchmark-ips', branch: 'master'
  gem 'net-ldap'
end
