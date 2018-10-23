require 'pathname'
ROOT = Pathname(__FILE__).dirname

if ENV['DEBUG']
  begin
    require 'pry-byebug'
  rescue LoadError
  end
end

require 'bundler/gem_tasks'

task default: [:spec]
