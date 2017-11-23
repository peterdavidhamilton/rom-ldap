module ROM
  module LDAP
    class Relation < ROM::Relation
      module Reading
        # Output the dataset as an LDIF string
        #
        # @return [String]
        #
        # @example
        #   relation.to_ldif
        #
        # @api public
        def to_ldif
          dataset.export(:ldif)
        end

        # Output the dataset as JSON
        #
        # @return [String]
        #
        # @api public
        def to_json
          dataset.export(:json)
        end

        # Output the dataset as YAML
        #
        # @return [String]
        #
        # @api public
        def to_yaml
          dataset.export(:yaml)
        end

        # Specify an alternative search base for the dataset or resets it.
        #
        # @example
        #   relation.base("cn=department,ou=users,dc=org")
        #
        # @return [Relation]
        #
        # @api public
        def base(alt_base = self.class.base)
          new(dataset.search_base(alt_base))
        end

        # Compliments #root method with an alternative search base
        # selected from a class level hash.
        #
        # @param key [Symbol]
        #
        # @api public
        def branch(key)
          base(self.class.branches[key])
        end

        # Standard directory query. Supersede criteria with the given filter string.
        #
        # @param raw [String] Valid LDAP filter string
        #
        # @return [Relation]
        #
        # @api public
        def search(raw)
          new(dataset[raw])
        end

        # Returns empty dataset if the filtered entity cannot bind.
        #
        # @return [Relation]
        #
        # @api public
        def authenticate(password)
          dataset.authenticated?(password) ? new(dataset) : new(EMPTY_ARRAY)
        end

        # Returns True if the filtered entity can bind.
        #
        # @return [Boolean]
        #
        # @api public
        def authenticated?(password)
          dataset.authenticated?(password)
        end

        # Count the number of entries selected from the paginated dataset.
        #
        # @return [Integer]
        #
        # @api public
        def count
          dataset.count
        end

        # Count the number of entries in the dataset.
        #   Unrestricted by the gateway search limit.
        #
        # @return [Integer]
        #
        # @api public
        def total
          dataset.total
        end

        # @return [Boolean]
        #
        # @api public
        def one?
          dataset.one?
        end
        alias distinct? one?
        alias unique? one?

        # @return [Boolean]
        #
        # @api public
        def any?
          dataset.any?
        end
        alias exist? any?

        # @return [Boolean]
        #
        # @api public
        def none?
          dataset.none?
        end

        # Find tuple by primary_key - required by commands
        #
        # @param pk [Mixed] single values
        #
        # @example
        #   relation.by_pk(1001)
        #   relation.by_pk('uid=test1,ou=users,dc=example,dc=com')
        #
        # @return [Relation]
        def by_pk(pk)
          if primary_key == :dn
            new(dataset.fetch(pk))
          else
            where(primary_key => pk)
          end
        end

        # Fetch a tuple identified by the pk
        #
        # @example
        #   users.fetch(1001) # => {:id => 1, name: "Jane"}
        #
        # @return [Hash]
        #
        # @raise [ROM::TupleCountMismatchError] When 0 or more than 1 tuples were found
        #
        # @api public
        def fetch(pk)
          by_pk(pk).one!
        end

        # First tuple from the relation
        #
        # @example
        #   relation.where(sn: 'smith').first
        #
        # @return [Hash]
        #
        # @api public
        def first
          dataset.first
        end

        # Last tuple from the relation
        #
        # @example
        #   relation.where(sn: 'smith').last
        #
        # @return [Hash]
        #
        # @api public
        def last
          dataset.reverse_each.first
        end

        # Orders the dataset by a given attribute
        #
        # @param attribute [Symbol]
        #
        # @example
        #   relation.order(:given_name)
        #
        # @return [Relation]
        #
        # @api public
        def order(attribute)
          new(dataset.sort_by { |e| e[attribute] })
        end

        # Limits the dataset to a number of tuples
        #
        # @example
        #   relation.limit(6)
        #
        # @return [Relation]
        #
        # @api public
        def limit(number)
          new(dataset.take(number))
        end

        # Shuffles the dataset
        #
        # @example
        #   relation.random
        #
        # @return [Relation]
        #
        # @api public
        def random
          new(dataset.entries.shuffle)
        end

        # Reverses the dataset
        #
        # @example
        #   relation.reverse
        #
        # @return [Relation]
        #
        # @api public
        def reverse
          new(dataset.reverse_each)
        end

        # Selects on certain attributes from tuples
        #
        # @example
        #   relation.where(sn: 'smith').select(:dn, :sn, :uid)
        #
        # @return [Relation]
        #
        # @api public
        def select(*args)
          new(dataset.map { |e| e.select { |k, _v| args.include?(k) } })
        end
        alias pluck select

        # Filters entities by pattern against canonical hash.
        #
        # @see Directory::Entity.to_str
        #
        # @param pattern [Mixed]
        #
        # @return [Relation]
        #
        # @example
        #   relation.find(/regexp/)
        #   relation.find(23..67)
        #
        # @api public
        def find(pattern)
          new(dataset.grep(pattern))
        end

        # Filters entities by inverse of pattern
        #
        # @see #find
        #
        # @api public
        def find_inverse(pattern)
          new(dataset.grep_v(pattern))
        end

        # Qualifies all columns in a relation
        #
        # This method is intended to be used internally within a relation object
        #
        # @example
        #   users.qualified.dataset.sql
        #   # SELECT "users"."id", "users"."name" ...
        #
        # @return [Relation]
        #
        # @api public
        def qualified
          binding.pry
          schema.qualified.call(self)
        end

        def join(*args)
          binding.pry
        end
      end
    end
  end
end
