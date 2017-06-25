# encoding: utf-8
# frozen_string_literal: true

require 'rom/types'

module ROM
  module Ldap
    module Types
      include ROM::Types

      Input     = Types::Coercible::String

      Attribute = Types::Coercible::Array.member(Input)

      Jpeg      = Dry::Types::Definition.new(::String).constructor ->(binary) {
        [
          'data:image/jpeg;base64,',
          Base64.strict_encode64(binary[0])
        ].join
      }

    end
  end
end
