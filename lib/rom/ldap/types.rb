# encoding: utf-8
# frozen_string_literal: true

require 'rom/types'

module ROM
  module Ldap
    module Types
      include ROM::Types
       DistinguishedName = Strict::String
    end
  end
end
