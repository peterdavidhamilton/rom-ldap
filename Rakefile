if ENV['DEBUG']
  begin
    require 'pry-byebug'
  rescue LoadError
  end
end

require 'bundler/gem_tasks'

load 'rom/ldap/tasks/ldap.rake'

task default: [:spec]
