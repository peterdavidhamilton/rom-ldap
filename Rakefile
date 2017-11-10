begin
  require 'pry-byebug'
rescue LoadError
end if ENV['PRY']

require 'bundler/gem_tasks'

Rake.add_rakelib 'rakelib'

task default: [:spec]
