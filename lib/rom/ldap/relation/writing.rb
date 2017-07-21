module ROM
  module LDAP
    class Relation < ROM::Relation
      module Writing

        # @example
        #
        # repo.insert(
        #   dn: 'uid=batman,ou=users,dc=test',
        #   cn: 'The Dark Knight',
        #   uid: 'batman',
        #   sn: 'Wayne',
        #   uidnumber: 1003,
        #   gidnumber: 1050,
        #   'apple-imhandle': 'bruce-wayne',
        #   objectclass: %w[extensibleobject inetorgperson apple-user]
        # )
        #
        # @param [Hash]
        #
        # @return [Struct]
        #
        def insert(*args)
          dataset.add(*args)
        end

        # @example  repo.update(2000, mail: 'fear_the_bat@gotham.com')
        #
        def update(args)
          tuples = dataset.entries
          dataset.modify(tuples, args)
        end

        # @example  repo.delete(2000)
        #
        def delete
          tuples = dataset.entries
          dataset.delete(tuples)
        end

      end
    end
  end
end
