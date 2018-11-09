require 'rom/types'

module ROM
  module LDAP
    module Types
      include ROM::Types

      # Single Values --------
      Octet   = Constructor(String,  ->(v) { Functions[:to_hex][v][0] }).meta(octet: true)
      Binary  = Constructor(String,  ->(v) { Functions[:to_binary].(v[0]) }).meta(binary: true)
      String  = Constructor(String,  ->(v) { Functions[:stringify].(v[0]) })
      Integer = Constructor(Integer, ->(v) { Functions[:map_to_integers][v][0] })
      Symbol  = Constructor(Symbol,  ->(v) { Functions[:map_to_symbols][v][0] })
      Time    = Constructor(Time,    ->(v) { Functions[:map_to_times][v][0] })
      Bool    = Constructor(Bool,    ->(v) { Functions[:map_to_booleans][v][0] })

      # Multiple Values --------
      Octets    = Array.constructor(Functions[:to_hex]).meta(octet: true)
      Binaries  = Array.constructor(Functions[:to_binary]).meta(binary: true)
      Strings   = Array.constructor(Functions[:stringify])
      Integers  = Array.constructor(Functions[:map_to_integers])
      Symbols   = Array.constructor(Functions[:map_to_symbols])
      Times     = Array.constructor(Functions[:map_to_times])
      Bools     = Array.constructor(Functions[:map_to_booleans])

      # Special LDAP Read Types --------
      Address   = Constructor(String, ->(v) { v.split('$').map(&:strip) })
      # Addresses = Constructor(Array, ->(v) { v.map { |a| a.split('$').map(&:strip) }.first })
    end
  end
end
