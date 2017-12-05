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
        # @param tuple [Hash]
        #
        # @return [Array<Directory::Entry, Boolean>]
        #
        # @api public
        def insert(tuple)
          dataset.add(tuple)
        end

        # @example
        #   repo.update(2000, mail: 'fear_the_bat@gotham.com')
        #   #=>  {}
        #
        # @param tuple [Hash]
        #
        # @return [Array<Directory::Entry, Boolean>]
        #
        # @api public
        def update(tuple)
          dataset.modify(tuple)
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
