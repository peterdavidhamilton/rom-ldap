# frozen_string_literal: true

module ROM
  module LDAP
    MessageQueue = Hash.new { |hash, key| hash[key] = [] }
  end
end
