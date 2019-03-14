module ROM
  module LDAP
    class Dataset
      module Persistence
        # Interface to Directory#add
        #
        # @param tuple [Hash]
        #
        # @return [Boolean]
        #
        # @api public
        def add(tuple)
          directory.add(tuple)
        end

        # Interface to Directory#modify
        #
        # @param tuple [Changeset, Hash] Modification params
        #
        # @return [Array<Directory::Entry, Boolean>]
        #
        # @api public
        def modify(tuple)
          map { |e| directory.modify(e.dn, tuple) }
        end

        # Interface to Directory#delete
        #
        # @see Directory::Operations#delete
        #
        # @return [Array<Directory::Entry, Boolean>]
        #
        # @api public
        def delete
          map { |e| directory.delete(e.dn) }
        end
      end
    end
  end
end
