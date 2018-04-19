# Make a 'default' docker machine to run the 'osixia/openldap' image.
# https://github.com/osixia/docker-openldap
#
# `$ docker-machine create -d virtualbox default`
# `$ eval $(docker-machine env)`
# `$ docker run --name ldap -p 3897:389 --detach osixia/openldap:1.2.0`
# `$ ldapsearch -x -H ldap://$(docker-machine ip):3897 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin +`
# `$ ldapsearch -x -h $(docker-machine ip):3897 -b "" -s base "(objectClass=*)" supportedControl supportedExtension supportedFeatures`

require 'rom-ldap'

opts = {
  username: 'cn=admin,dc=example,dc=org',
  password: 'admin',
  uri:      '192.168.99.101:3897',
  base:     'dc=example,dc=org',
  timeout:  10,
  logger:   Logger.new(STDOUT)
}

configuration = ROM::Configuration.new(:ldap, opts)


configuration.relation(:foo, adapter: :ldap) do
  schema('(cn=*)', infer: true)

  use :auto_restrictions
end

ROM::LDAP.load_extensions :compatible_entry_attributes

container = ROM.container(configuration)

foo = container.relations[:foo]

foo.to_a
