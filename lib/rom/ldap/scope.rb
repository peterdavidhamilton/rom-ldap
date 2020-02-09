module ROM
  module LDAP
    #
    # Search Scope
    #
    # @see https://ldapwiki.com/wiki/LDAP%20Search%20Scopes
    #
    # Constrained to the entry named by baseObject.
    SCOPE_BASE  = 0 # "base"
    # Constrained to the immediate subordinates of the entry named by baseObject.
    SCOPE_ONE   = 1 # "one"
    # Constrained to the entry named by baseObject and to all its subordinates.
    SCOPE_SUB   = 2 # "sub"

    SCOPES = [SCOPE_BASE, SCOPE_ONE, SCOPE_SUB].freeze
  end
end
