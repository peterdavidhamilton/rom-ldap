source 'https://rubygems.org'

gemspec

gem 'ldap-ber', git: "https://oauth2:#{ENV['GITLAB_TOKEN']}@gitlab.com/peterdavidhamilton/ldap-ber", branch: 'develop'

gem 'rom', git: 'https://github.com/rom-rb/rom' do
  gem 'rom-changeset'
  gem 'rom-core'
  gem 'rom-mapper'
  gem 'rom-repository'
end

group :development do
  gem 'awesome_print'
  gem 'pry', platforms: %i[jruby rbx]
  gem 'pry-byebug', platforms: :mri
  gem 'yard-junk'
  gem 'rubocop-performance'

  gem 'dry-monitor'         # @see bin/console
  gem 'rouge'               # @see lib/dry/monitor/ldap/logger.rb
end

group :test do
  # gem 'codeclimate-test-reporter'
  gem 'msgpack', '~> 1.2.4' # @see spec/unit/relation/export_spec.rb
  gem 'libxml-ruby'         # @see spec/unit/relation/export_spec.rb
  gem 'rom-factory'
  gem 'rspec'
  gem 'rubocop', '~> 0.58'
  gem 'rubocop-performance'
  gem 'simplecov'
end

group :benchmark do
  gem 'benchmark-ips'
  gem 'net-ldap'
end
