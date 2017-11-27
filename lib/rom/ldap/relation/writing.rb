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
        #     uid_number: 1003,
        #     gid_number: 1050,
        #     apple_imhandle: 'bruce-wayne',
        #     object_class: %w[extensibleObject inetOrgPerson apple-user]
        #   )
        #     #=>
        #   {
        #     dn: 'uid=batman,ou=users,dc=test',
        #     cn: 'The Dark Knight',
        #     uid: 'batman',
        #     sn: 'Wayne',
        #     uid_number: 1003,
        #     gid_number: 1050,
        #     apple_imhandle: 'bruce-wayne',
        #     object_class: %w[extensibleObject inetOrgPerson apple-user]
        #   }
        #
        # @param args [Hash]
        #
        # @return [Array<Directory::Entry, Boolean>]
        #
        # @api public
        def insert(args)
          dataset.add(args)
        end

        # @example
        #   repo.update(2000, mail: 'fear_the_bat@gotham.com')
        #   #=>  {}
        #
        # @param args [Hash]
        #
        # @return [Array<Directory::Entry, Boolean>]
        #
        # @api public
        def update(args)
          dataset.modify(args)
        end

        # @example
        #   repo.delete(2000) #=> true
        #
        # @return [Array<Boolean>]
        #
        # @api public
        def delete
          dataset.delete
        end
      end
    end
  end
end
