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

      def self.ForeignKey(relation, type = Types::Int.meta(index: true))
        super
      end

      UUID_REGEX = /\A
                  [\da-fA-F]{8}-
                  ([\da-fA-F]{4}-){3}
                  [\da-fA-F]{12}
                  \z/x.freeze

      UUID   = Types::Strict::String.constrained(format: UUID_REGEX)
      Octet  = Types.Constructor(::String, ->(v) { v.force_encoding('UTF-8') })
      Postal = Types.Constructor(::String, ->(v) { v.split('$') })
      Serial = Int.meta(primary_key: true)
      DN     = String.meta(primary_key: true)

      module Single
        String = Types.Constructor(::String,    ->(v) { v.first.to_s                 })
        Bool   = Types.Constructor(Types::Bool, ->(v) { Functions[:to_bool][v].first })
        Int    = Types.Constructor(::Integer,   ->(v) { Functions[:to_int][v].first  })
        Symbol = Types.Constructor(::Symbol,    ->(v) { Functions[:to_sym][v].first  })
        Time   = Types.Constructor(::Time,      ->(v) { Functions[:to_time][v].first })
        Array  = Types::Array
      end

      module Multiple
        String = Types::Coercible::Array.member(Types::Coercible::String)
        Int    = Types::Coercible::Array.member(Types::Coercible::Int)
        Bool   = Types.Constructor(Types::Bool, ->(v) { Functions[:to_bool][v] })
        Symbol = Types.Constructor(::Symbol,    ->(v) { v.map(&:to_sym)        })
        Time   = Types.Constructor(::Time,      ->(v) { Functions[:to_time][v] })
        Array  = Types::Array
      end
    end
  end
end
