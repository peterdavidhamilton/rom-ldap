require 'rom/types'

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

    end
  end
end
