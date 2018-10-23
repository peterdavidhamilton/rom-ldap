require 'yaml'
#
# @example
#   bundle exec rake ldif[foo]
#
desc 'Populate directory tree'
task :ldif, [:file] do |t, file:|

  if file.nil?
    abort("`$ rake ldif[schema]` to load './spec/support/schema.ldif'")
  end

  config    = YAML.load_file(ROOT.join('spec/support/config.yml'))
  ldif_path = ROOT.join('spec/support')
  host      = config.fetch(:host, '127.0.0.1')
  port      = config.fetch(:port, 10389)
  admin     = config.fetch(:admin, 'uid=admin,ou=system')
  password  = config.fetch(:password, 'secret')

  system("ldapmodify \
            -h #{host} \
            -p #{port} \
            -D #{admin} \
            -w #{password} \
            -a -c \
            -f #{ldif_path}/#{file}.ldif")

end
