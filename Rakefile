begin
  require 'pry-byebug'
rescue LoadError
end if ENV['DEBUG']

require 'bundler/gem_tasks'
require 'rake/testtask'
Rake.add_rakelib 'rakelib'

task default: :test
