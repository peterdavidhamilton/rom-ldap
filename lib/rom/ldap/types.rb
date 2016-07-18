# encoding: utf-8
# frozen_string_literal: true

require 'rom/types'

module ROM
  module Ldap
    module Types
      include ROM::Types

      # Serial = Strict::Int.constrained(gt: 0).meta(primary_key: true)
    end
  end
end
