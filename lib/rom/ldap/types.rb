require 'rom/types'

module ROM
  module LDAP
    module Types
      include ROM::Types

      # Single Values --------
      Octet   = Constructor(String,  ->(v) { Functions[:to_hex][v][0]     }).meta(octet: true)
      Binary  = Constructor(String,  ->(v) { Functions[:to_binary].(v[0]) }).meta(binary: true)
      String  = Constructor(String,  ->(v) { Functions[:stringify].(v[0]) })
      Int     = Constructor(Integer, ->(v) { Functions[:to_int][v][0]     })
      Symbol  = Constructor(Symbol,  ->(v) { Functions[:to_sym][v][0]     })
      Time    = Constructor(Time,    ->(v) { Functions[:to_time][v][0]    })
      Bool    = Constructor(Bool,    ->(v) { Functions[:to_bool][v][0]    })

      # Multiple Values --------
      Strings   = Array.constructor(Functions[:stringify])
      Ints      = Array.constructor(Functions[:to_int])
      Symbols   = Array.constructor(Functions[:to_sym])
      Times     = Array.constructor(Functions[:to_time])
      Bools     = Array.constructor(Functions[:to_bool])
      Octets    = Array.constructor(Functions[:to_hex]).meta(octet: true)
      Binaries  = Array.constructor(Functions[:to_binary]).meta(binary: true)

    end
  end
end
