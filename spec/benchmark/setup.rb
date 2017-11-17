require 'bundler'
Bundler.setup

require 'pry'
require 'logger'
require 'benchmark/ips'

require 'rom-ldap'

Types = ROM::LDAP::Types

require 'net-ldap'

logger = Logger.new(IO::NULL)

# CONFIG -------------------------------------
host     = '127.0.0.1'
port     = 10389
admin    = 'uid=admin,ou=system'
password = 'secret'
filter   = '(&(objectclass=person)(uid=*))'
base     = 'ou=users,dc=example,dc=com'

# ROM-LDAP -------------------------------------
directory = { server: "#{host}:#{port}", username: admin, password: password}
conf = ROM::Configuration.new(:ldap, directory, base: base, logger: logger)


# ROM::LDAP::Directory::Entity.to_method_name!

conf.relation(:infer_hash) do
  schema(filter, infer: true)
  auto_struct false
end

conf.relation(:infer_struct) do
  schema(filter, infer: true)
  auto_struct true
end

conf.relation(:explicit_struct) do
  schema(filter) do
    attribute 'uid',       Types::String, read: Types::Single::String
    attribute 'uidNumber', Types::Int,    read: Types::Single::Int
  end
  auto_struct true
end

conf.relation(:explicit_hash) do
  schema(filter) do
    attribute 'uid',       Types::String, read: Types::Single::String
    attribute 'uidNumber', Types::Int,    read: Types::Single::Int
  end
  auto_struct false
end



container        = ROM.container(conf)
@infer_hash      = container.relations[:infer_hash]
@infer_struct    = container.relations[:infer_struct]
@explicit_hash   = container.relations[:explicit_hash]
@explicit_struct = container.relations[:explicit_struct]


# NET-LDAP -------------------------------------
@net_ldap = Net::LDAP.new(
  host: host, port: port, base: base,
  auth: { method: :simple, username: admin, password: password }
)

