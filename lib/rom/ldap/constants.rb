# encoding: utf-8
# frozen_string_literal: true

module ROM
  module Ldap

    FILTERS = [
      :above,
      :below,
      :between,
      :exclude,
      :match,
      :not,
      :prefix,
      :suffix,
      :where,
      :with_attribute
    ].freeze

    METHODS = [
      :begins,
      :construct,
      :contains,
      :ends,
      :escape,
      :equals,
      :ge,
      :le,
      :negate,
      :present
    ].freeze

  end
end
