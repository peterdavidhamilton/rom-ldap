module ROM
  module LDAP
    class Relation < ROM::Relation

      #
      # Default Global Filters
      #
      GROUPS = '(|(objectClass=group)(objectClass=groupOfNames))'.freeze
      USERS  = '(|(objectClass=inetOrgPerson)(objectClass=user))'.freeze

      # Find all groups a user belongs to

      # "(&(objectclass=groupOfUniqueNames)(uniqueMember=uid=myuser,dc=mydomain,dc=com))".freeze

    end
  end
end
