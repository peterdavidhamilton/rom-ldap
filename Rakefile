begin
  require 'pry-byebug'
rescue LoadError
end if ENV['DEBUG']

require 'bundler/gem_tasks'

Rake.add_rakelib 'rakelib'

task default: :test
