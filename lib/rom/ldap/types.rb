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

      Serial    = Int.meta(primary_key: true)

      Void      = Nil

      Input     = Types::Coercible::String

      Entry     = Types::Coercible::Array.member(Input)

      Jpeg      = Definition(::String).constructor ->(input) {
        input.map do |image|
          ['data:image/jpeg;base64,', Base64.strict_encode64(image)].join
        end
      }

      module Single
        String = Types.Constructor(::String,  ->(v) { v.first.to_s })
        Int    = Types.Constructor(::Integer, ->(v) { v.first.to_s.to_i })
        Symbol = Types.Constructor(::Symbol,  ->(v) { v.first.to_s.to_sym })
      end

      module Multiple
        String = Types.Constructor(::String,  ->(v) { v.map(&:to_s) })
        Int    = Types.Constructor(::Integer, ->(v) { v.map(&:to_i) })
        Symbol = Types.Constructor(::Symbol,  ->(v) { v.map(&:to_sym) })
      end
    end
  end
end
