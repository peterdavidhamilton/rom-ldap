require 'rom/types'
require 'base64'

module ROM
  module LDAP
    module Types
      include ROM::Types

      def self.Constructor(*args, &block)
        ROM::Types.Constructor(*args, &block)
      end

      def self.Definition(*args, &block)
        ROM::Types.Definition(*args, &block)
      end

      String  = Constructor(::String,    ->(v) { Functions[:stringify].(v[0]) })
      Int     = Constructor(::Integer,   ->(v) { Functions[:to_int][v][0]  })
      Symbol  = Constructor(::Symbol,    ->(v) { Functions[:to_sym][v][0]  })
      Time    = Constructor(::Time,      ->(v) { Functions[:to_time][v][0] })
      Bool    = Constructor(Types::Bool, ->(v) { Functions[:to_bool][v][0] })

      Strings = Constructor(::String,    Functions[:stringify])
      Ints    = Constructor(::Integer,   Functions[:to_int])
      Symbols = Constructor(::Symbol,    Functions[:to_sym])
      Times   = Constructor(::Time,      Functions[:to_time])
      Bools   = Constructor(Types::Bool, Functions[:to_bool])


      UUID_REGEX = /\A
                  [\da-fA-F]{8}-
                  ([\da-fA-F]{4}-){3}
                  [\da-fA-F]{12}
                  \z/x

      UUID    = Types::Strict::String.constrained(format: UUID_REGEX)
      Array   = Types::Strict::Array
      Octet   = Constructor(::String, ->(v) { v.force_encoding('UTF-8') })
      Postal  = Constructor(::String, ->(v) { v.split('$') })
      Serial  = Int.meta(primary_key: true)
      DN      = String.meta(primary_key: true)
    end
  end
end
