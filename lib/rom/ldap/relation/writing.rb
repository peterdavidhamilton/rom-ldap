module ROM
  module LDAP
    class Relation < ROM::Relation

      module Writing
        # @example
        #   relation.insert(
        #     dn: 'uid=batman,ou=comic,dc=rom,dc=ldap',
        #     cn: 'The Dark Knight',
        #     uid: 'batman',
        #     given_name: 'Bruce',
        #     sn: 'Wayne',
        #     apple_imhandle: 'bruce-wayne',
        #     object_class: %w[extensibleObject inetOrgPerson]
        #   )
        #     #=>
        #   {
        #     dn: 'uid=batman,ou=comic,dc=rom,dc=ldap',
        #     cn: 'The Dark Knight',
        #     uid: 'batman',
        #     given_name: 'Bruce',
        #     sn: 'Wayne',
        #     apple_imhandle: 'bruce-wayne',
        #     object_class: %w[top extensibleObject inetOrgPerson]
        #   }
        #
        # @param tuple [Hash]
        #
        # @return [Array<Directory::Entry, FalseClass>]
        #
        # @api public
        def insert(tuple)
          dataset.add(tuple)
        end

        # @example
        #   relation.update(2000, mail: 'fear_the_bat@gotham.com')
        #   #=>  {}
        #
        # @param tuple [Hash]
        #
        # @return [Array<Directory::Entry, FalseClass>]
        #
        # @api public
        def update(tuple)
          dataset.modify(tuple)
        end

        # @example
        #   relation.delete('uid=batman,ou=users,dc=test') #=> { uid: 'batman'}
        #
        # @return [Array<Directory::Entry, FalseClass>]
        #
        # @api public
        def delete
          dataset.delete
        end
      end

    end
  end
end
