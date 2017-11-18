require_relative 'setup'

# Comparison:
#               net-ldap:      429.5 i/s
# rom-ldap explicit hash:      248.9 i/s - 1.73x  slower
# rom-ldap inferred hash:      241.6 i/s - 1.78x  slower
#
# Enable snake-case function

Benchmark.ips do |bm|

  bm.config(time: 5, warmup: 0.5, iterations: 2)

  #
  # Structs inferred and explicit
  #
  bm.report('rom-ldap inferred struct') do
    binding.pry
    @infer_struct.to_a
  end

  bm.report('rom-ldap explicit struct') do
    @explicit_struct.to_a
  end

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
