if ENV['DEBUG']
  begin
    require 'pry-byebug'
  rescue LoadError
  end
end

require 'bundler/gem_tasks'

load 'rom/ldap/tasks/ldap.rake'
load 'rom/ldap/tasks/ldif.rake'

task default: [:spec]
