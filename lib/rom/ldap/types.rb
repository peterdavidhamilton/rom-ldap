# encoding: utf-8
# frozen_string_literal: true

require 'rom/types'

module ROM
  module Ldap
    module Types
      include ROM::Types

      Attribute = Types::Strict::String.constructor do |v|
        if v.is_a?(Enumerable)
          v.first.to_s unless v.empty?
        end
      end

      Attributes = Types::Strict::Array.member(Types::Strict::String)
      Field = Attribute | Attributes
    end
  end
end
