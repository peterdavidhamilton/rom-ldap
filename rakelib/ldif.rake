require 'psych'

desc 'Populate directory tree'
task :ldif, [:file] do |t, args|
  ldapmodify(file: "./spec/support/#{args[:file]}.ldif")
end

def ldapmodify(file:)
  host     = config.fetch(:host, '127.0.0.1')
  port     = config.fetch(:port, 10389)
  admin    = config.fetch(:admin, 'uid=admin,ou=system')
  password = config.fetch(:password, 'secret')

  system "ldapmodify -h #{host} -p #{port} -D #{admin} -w #{password} -a -c -f #{file}"
end

def config
  @config ||= Psych.load_file('./spec/support/config.yml')
end
