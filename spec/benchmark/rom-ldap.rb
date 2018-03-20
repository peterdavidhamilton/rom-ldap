#
# $ bundle exec ruby ./ruby-ldap.rb
#

# require 'bundler'
# Bundler.setup
require 'bundler/setup'

require 'pry'
require 'logger'
require 'benchmark/ips'
require 'rom-ldap'
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

# Attribute name formatter
ROM::LDAP.load_extensions :compatible_entry_attributes


conf.relation(:infer) do
  schema(filter, infer: true)
  auto_struct false
end

conf.relation(:explicit) do
  schema(filter) do
    attribute :uid,               ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
    attribute :cn,                ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
    attribute :dn,                ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
    attribute :given_name,        ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
    attribute :sn,                ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
    attribute :mail,              ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
    attribute :user_password,     ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
    attribute :uid_number,        ROM::LDAP::Types::Int,    read: ROM::LDAP::Types::Single::Int
    attribute :create_timestamp,  ROM::LDAP::Types::Time,   read: ROM::LDAP::Types::Single::Time
    attribute :object_class,      ROM::LDAP::Types::Array,  read: ROM::LDAP::Types::Array
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
    @net_ldap.search(filter: filter, base: base, attributes: %w[* +]).to_a
  end

  bm.report('rom-ldap inferred schema hash') do
    @infer.to_a
  end

  bm.report('rom-ldap explicit schema struct') do
    @explicit.to_a
  end

  bm.compare!
end
