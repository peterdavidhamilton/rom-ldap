cwd = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
$LOAD_PATH.unshift(cwd)

require 'pry-byebug'
require 'rom-ldap'

conf = ROM::Configuration.new(
  directory: [
    :ldap,
    { server: '127.0.0.1:10389', username: 'uid=admin,ou=system', password: 'secret' },
    { base: 'dc=example,dc=com' }
  ],
)

conf.relation(:animals, adapter: :ldap) do
  gateway :directory
  base    'dc=example,dc=com'.freeze
  branches({
            pets: 'cn=domestic,ou=groups,dc=example,dc=com',
            zoo:  'cn=wild,ou=groups,dc=example,dc=com'
          }.freeze)

  schema('(species=*)', as: :animals, infer: true)
  use :pagination
  per_page 4
  use :auto_restrictions

  def pets
    branch(:pets)
  end

  def zoo
    branch(:zoo)
  end
end

container = ROM.container(conf)
animals   = container.relations[:animals]

# animals.base('cn=domestic,ou=groups,dc=example,dc=com').count
# people.zoo.search('(cn=school*)').count
# people.pets.page(1).search('(cn=*1234*)').first
