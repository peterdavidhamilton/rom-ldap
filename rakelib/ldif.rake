require 'yaml'
require 'pry'
#
# Leverage LDAP environment variables using ./ldaprc
#
# `$ echo -n secret > ./ldappw`
#
# @example
#   $ rake ldif            # => ./example/ldif/animals.ldif
#   $ rake ldif[file]      # => ./example/ldif/file.ldif
#   $ rake ldif[file,path] # => ./path/file.ldif
#
desc 'Populate directory tree'
task :ldif, [:file, :path] do |_t, args|

  # ARGV.each do |argv|
  #   if argv =~ /(.+)\=(.+)/
  #     config[Regexp.last_match(1).delete('-').to_sym] = Regexp.last_match(2)
  #   end
  # end

  args.with_defaults(file: 'animals', path: 'example/ldif')
  path = ROOT.join(args[:path])
  ldif = "#{path}/#{args[:file]}.ldif"

  # simple authenticated continuous add operation
  system("ldapmodify -x -y ldappw -a -c -f #{ldif}")
end
