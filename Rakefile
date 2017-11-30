if ENV['PRY']
  begin
    require 'pry-byebug'
  rescue LoadError
  end
end

require 'bundler/gem_tasks'

task default: [:spec]
