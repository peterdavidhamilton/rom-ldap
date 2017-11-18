require_relative 'setup'

# Comparison:
# rom-ldap explicit hash:      504.0 i/s
# rom-ldap inferred hash:      502.5 i/s - same-ish: difference falls within error
#               net-ldap:      430.5 i/s - 1.17x  slower
#
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
