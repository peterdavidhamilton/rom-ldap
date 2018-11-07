require 'bundler'

Bundler.require

ROM::LDAP.load_extensions :compatibility

opts = {
  username: 'uid=admin,ou=system'
  password: 'secret'
  base: 'dc=rom,dc=ldap'
  logger: Logger.new(IO::NULL)
}



# ROM-LDAP -------------------------------------
config = ROM::Configuration.new(:ldap, opts) do |conf|
  conf.relation(:infer) do
    schema('(objectclass=person)', infer: true)
  end

  conf.relation(:explicit) do
    schema('(objectclass=person)') do
      attribute :uid,               ROM::LDAP::Types::String
      attribute :cn,                ROM::LDAP::Types::String
      attribute :dn,                ROM::LDAP::Types::String
      attribute :given_name,        ROM::LDAP::Types::String
      attribute :sn,                ROM::LDAP::Types::String
      attribute :mail,              ROM::LDAP::Types::String
      attribute :user_password,     ROM::LDAP::Types::String
      attribute :uid_number,        ROM::LDAP::Types::Integer
      attribute :create_timestamp,  ROM::LDAP::Types::Time
      attribute :object_class,      ROM::LDAP::Types::Strings
    end
    auto_struct true
  end
end

container = ROM.container(config)


# NET-LDAP -------------------------------------
net_ldap = Net::LDAP.new(
  host: ENV['LDAPHOST'],
  port: ENV['LDAPPORT'],
  base: opts[:base],
  auth: {
    method: :simple,
    username: opts[:username],
    password: opts[:password]
  }
)




# BENCHMARKS -------------------------------------
Benchmark.ips do |bm|

  bm.config(time: 5, warmup: 0.5, iterations: 2)

  bm.report('net-ldap') do
    net_ldap.search(filter: '(objectclass=person)', base: opts[:base], attributes: %w[* +]).to_a
  end

  bm.report('rom-ldap inferred schema hash') do
    container.relations[:infer].to_a
  end

  bm.report('rom-ldap explicit schema struct') do
    container.relations[:explicit].to_a
  end

  bm.compare!
end
