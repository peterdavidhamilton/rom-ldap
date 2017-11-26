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


ROM::LDAP::Directory::Entry.to_method_name!

conf.relation(:infer) do
  schema(filter, infer: true)
  auto_struct false
end

conf.relation(:explicit) do
  schema(filter) do
    attribute :uid,               Types::String, read: Types::Single::String
    attribute :cn,                Types::String, read: Types::Single::String
    attribute :dn,                Types::String, read: Types::Single::String
    attribute :given_name,        Types::String, read: Types::Single::String
    attribute :sn,                Types::String, read: Types::Single::String
    attribute :mail,              Types::String, read: Types::Single::String
    attribute :user_password,     Types::String, read: Types::Single::String
    attribute :uid_number,        Types::Int,    read: Types::Single::Int
    attribute :create_timestamp,  Types::Time,   read: Types::Single::Time
    attribute :object_class,      Types::Array,  read: Types::Array
  end
  auto_struct true
end

container = ROM.container(conf)
@infer    = container.relations[:infer]
@explicit = container.relations[:explicit]


# NET-LDAP -------------------------------------
@net_ldap = Net::LDAP.new(
  host: host, port: port, base: base,
  auth: { method: :simple, username: admin, password: password }
)

Benchmark.ips do |bm|

  bm.config(time: 5, warmup: 0.5, iterations: 2)

  bm.report('net-ldap') do
    @net_ldap.search(filter: filter, base: base, attributes: ['*', '+']).to_a
  end

  bm.report('rom-ldap inferred schema hash') do
    @infer.to_a
  end

  bm.report('rom-ldap explicit schema struct') do
    @explicit.to_a
  end

  bm.compare!
end
