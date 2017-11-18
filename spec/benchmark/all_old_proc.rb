require_relative 'setup'

# Comparison:
# rom-ldap explicit hash:      477.1 i/s
# rom-ldap inferred hash:      458.8 i/s - same-ish: difference falls within error
#             net-ldap:        431.0 i/s - 1.11x  slower
#
# custom function
ROM::LDAP::Directory::Entity.use_formatter(
  ->(key) {
    key = key.to_s.downcase.tr('-', '')
    key = key[0..-2] if key[-1] == '='
    key.to_sym
  }
)

Benchmark.ips do |bm|

  bm.config(time: 5, warmup: 0.5, iterations: 2)

  #
  # Structs inferred and explicit
  #
  # bm.report('rom-ldap inferred struct') do
  #   @infer_struct.to_a
  # end

  # bm.report('rom-ldap explicit struct') do
  #   @explicit_struct.to_a
  # end

  #
  # Hashes inferred and explicit
  #
  bm.report('rom-ldap inferred hash') do
    @infer_hash.to_a
  end

  bm.report('rom-ldap explicit hash') do
    @explicit_hash.to_a
  end

  #
  # Net-LDAP
  #
  bm.report('net-ldap') do
    @net_ldap.search(filter: '(&(objectclass=person)(uid=*))').to_a
  end

  bm.compare!
end
