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

      Serial = Int.meta(primary_key: true)

      module Single
        String = Types.Constructor(::String,    ->(v) { v.first.to_s                 })
        Bool   = Types.Constructor(Types::Bool, ->(v) { Functions[:to_bool][v].first })
        Int    = Types.Constructor(::Integer,   ->(v) { Functions[:to_int][v].first  })
        Symbol = Types.Constructor(::Symbol,    ->(v) { Functions[:to_sym][v].first  })
        Time   = Types.Constructor(::Time,      ->(v) { Functions[:to_time][v].first })
        Array  = Types::Array
      end

      module Multiple
            # String = Types.Constructor(::String,  -> v { v.map(&:to_s)   })
            # Int    = Types.Constructor(::Integer, -> v { v.map(&:to_i)   })
            # Symbol = Types::Coercible::Array.member(Types::Symbol)
            # Bool   = Types::Coercible::Array.member(Types::Bool)


        String = Types::Coercible::Array.member(Types::Coercible::String)
        Int    = Types::Coercible::Array.member(Types::Coercible::Int)
        Bool   = Types.Constructor(Types::Bool, -> v { Functions[:to_bool][v] })
        Symbol = Types.Constructor(::Symbol,    -> v { v.map(&:to_sym)        })
        Time   = Types.Constructor(::Time,      -> v { Functions[:to_time][v] })
        Array  = Types::Array
      end

    end
  end
end
