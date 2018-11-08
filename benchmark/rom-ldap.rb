require 'bundler'
require 'pry'

Bundler.require

ROM::LDAP.load_extensions :compatibility

opts = {
  username: 'uid=admin,ou=system',
  password: 'secret',
  base: 'ou=animals,dc=rom,dc=ldap',
  logger: Logger.new(IO::NULL)
}

filter = '(objectclass=*)'

# ROM-LDAP -------------------------------------
config = ROM::Configuration.new(:ldap, opts) do |conf|
  conf.relation(:rom) { schema(filter, infer: true) }
end

rom = ROM.container(config)


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
    net_ldap.search(filter: filter, attributes: %w[* +]).to_a
  end

  bm.report('rom-ldap') do
    rom.relations[:rom].to_a
  end

  bm.compare!
end
