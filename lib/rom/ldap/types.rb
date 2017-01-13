# encoding: utf-8
# frozen_string_literal: true

require 'rom/types'

module ROM
  module Ldap
    module Types
      include ROM::Types

      Attribute = Types::Strict::String.constructor do |v|
        v.is_a?(Enumerable) ? (v.first.to_s unless v.empty?) : v.to_s
      end

      Attributes = Types::Strict::Array.member(Types::Strict::String)

      Field = Attribute | Attributes

      # Base64 encode JPEG image data
      Image = Dry::Types::Definition.new(::String).constructor -> (binary) do
        ['data:image/jpeg;base64,', Base64.strict_encode64(binary[0])].join
      end

      # ObjectClasses =
      # ['extensibleObject',
      #  'top',
      #  'organizationalPerson',
      #  'inetOrgPerson',
      #  'person']

    end
  end
end
