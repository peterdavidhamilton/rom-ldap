module ROM
  module LDAP
    MessageQueue = Hash.new { |hash, key| hash[key] = [] }
  end
end
