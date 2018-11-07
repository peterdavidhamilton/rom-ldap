#
# Leverage LDAP environment variables using ./ldaprc
# ldapmodify with simple authentication and continuous add operation.
#
# @example
#   $ rake ldif            # => ./example/ldif/animals.ldif
#   $ rake ldif[file]      # => ./example/ldif/file.ldif
#   $ rake ldif[file,path] # => ./path/file.ldif
#
desc 'Import LDIF files'
task :ldif, [:file, :path] do |_t, args|

  args.with_defaults(path: 'example/ldif', file: 'wildlife/domain')
  path = ROOT.join(args[:path])
  ldif = "#{path}/#{args[:file]}.ldif"

  system("ldapmodify -x -y ldappw -a -c -f #{ldif} -v")
end

# LDIF files in order
# rake ldif[wildlife/domain]
# rake ldif[wildlife/config]
# rake ldif[wildlife/attributes]
# rake ldif[wildlife/classes]


          # desc 'Import LDIF files'
# task :import, [:file, :path] do |_t, args|

#   args.with_defaults(file: 'animals', path: 'example/ldif/wildlife')
#   path = ROOT.join(args[:path])
#   # LDIF file merge
#   # includes =
#   #   %w[config attributes classes domain].map do |file|
#   #     "include: file://#{path}/#{file}.ldif"
#   #   end
# end



desc 'Search LDIF'
task :search do |_t, args|
  system("ldapsearch -x -y ldappw +")
end


