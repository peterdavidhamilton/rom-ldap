# encoding: utf-8
# frozen_string_literal: true

require 'rom/types'

module ROM
  module Ldap
    module Types
      include ROM::Types

      Attribute = Types::String.constructor do |v|
        if v.is_a?(Enumerable)
          v.one? ? v.first.to_s : v.map(&:to_s)
        else
          v.to_s
        end
      end

      # Base64 encode JPEG image data
      Image = Dry::Types::Definition.new(::String).constructor -> (binary) do
        ['data:image/jpeg;base64,', Base64.strict_encode64(binary[0])].join
      end

      ObjectClasses = Types::Strict::Array
      # extensibleObject
      # top
      # organizationalPerson
      # inetOrgPerson
      # person

    end
  end
end
