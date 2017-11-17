require_relative 'setup'

# ruby ./one.rb
#
# Warming up --------------------------------------
# rom-ldap inferred hash
#                        160.000  i/100ms
# rom-ldap explicit hash
#                        157.000  i/100ms
#             net-ldap   103.000  i/100ms
# rom-ldap inferred hash
#                        159.000  i/100ms
# rom-ldap explicit hash
#                        159.000  i/100ms
#             net-ldap   103.000  i/100ms
# Calculating -------------------------------------
# rom-ldap inferred hash
#                           1.617k (± 3.1%) i/s -      8.109k in   5.018237s
# rom-ldap explicit hash
#                           1.619k (± 2.3%) i/s -      8.109k in   5.010735s
#             net-ldap      1.062k (± 2.5%) i/s -      5.356k in   5.044468s
# rom-ldap inferred hash
#                           1.617k (± 2.8%) i/s -      8.109k in   5.020101s
# rom-ldap explicit hash
#                           1.612k (± 2.2%) i/s -      8.109k in   5.032269s
#             net-ldap      1.056k (± 3.2%) i/s -      5.356k in   5.075858s

# Comparison:
# rom-ldap inferred hash:     1616.6 i/s
# rom-ldap explicit hash:     1612.2 i/s - same-ish: difference falls within error
#               net-ldap:     1056.4 i/s - 1.53x  slower
#
#
Benchmark.ips do |bm|

  bm.config(time: 5, warmup: 0.5, iterations: 2)


  #
  # Structs inferred and explicit
  #
  # bm.report('rom-ldap inferred struct') do
  #   @infer_struct.where(uid: 'root').one
  # end

  # bm.report('rom-ldap explicit struct') do
  #   @explicit_struct.where(uid: 'root').one
  # end

  #
  # Hashes inferred and explicit
  #
  bm.report('rom-ldap inferred hash') do
    @infer_hash.where(uid: 'root').first
  end

  bm.report('rom-ldap explicit hash') do
    @explicit_hash.where(uid: 'root').first
  end

  #
  # Net-LDAP
  #
  bm.report('net-ldap') do
    @net_ldap.search(filter: 'cn=root').first
  end

  bm.compare!
end
