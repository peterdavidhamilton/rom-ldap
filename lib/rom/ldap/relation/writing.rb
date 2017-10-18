module ROM
  module LDAP
    class Relation < ROM::Relation
      module Writing

        # @example
        #   repo.insert(
        #     dn: 'uid=batman,ou=users,dc=test',
        #     cn: 'The Dark Knight',
        #     uid: 'batman',
        #     sn: 'Wayne',
        #     uidnumber: 1003,
        #     gidnumber: 1050,
        #     'apple-imhandle': 'bruce-wayne',
        #     objectclass: %w[extensibleobject inetorgperson apple-user]
        #   ) #=> true
        #
        # @param args [Hash]
        # @return [Boolean]
        # @api public
        #
        def insert(args)
          dataset.add(args)
        end

        # @example
        #   repo.update(2000, mail: 'fear_the_bat@gotham.com') #=> ??
        #
        # @param args [Hash]
        # @return [Array, <Hash>]
        # @api public
        #
        def update(args)
          dataset.modify(dataset.entries, args)
        end

        # @example
        #   repo.delete(2000) #=> true
        #
        # @param args [Hash]
        # @return [Array, <Hash>]
        # @api public
        #
        def delete(*args)
          dataset.delete(dataset.entries)
        end

      end
    end
  end
end
