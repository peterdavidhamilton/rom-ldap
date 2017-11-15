module ROM
  module LDAP
    class Relation < ROM::Relation
      module Reading
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
        # @param key
        #
        # @api public
        def include?(key)
          dataset.include?(key)
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
        # Selects on certain attributes from tuples
        #
        # @example
        #   relation.by_pk(1001)
        #
        # @return [Relation]
        def by_pk(pk)
          where(primary_key => pk)
        end

        # Fetch a tuple identified by the pk
        #
        # @example
        #   users.fetch(1001)
        #   # {:id => 1, name: "Jane"}
        #
        # @return [Hash]
        #
        # @raise [ROM::TupleCountMismatchError] When 0 or more than 1 tuples were found
        #
        # @api public
        def fetch(pk)
          by_pk(pk).one!
        end

        # raw filter to LDIF
        #
        # @example
        #   relation.to_ldif
        #
        # @return [String]
        #
        # @api public
        def to_ldif
          dataset.to_ldif
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

        # Specify an alternative search base for the dataset.
        #
        # @example
        #   relation.base("cn=department,ou=users,dc=org")
        #
        # @return [Relation]
        #
        # @api public
        def base(alt_base)
          new(dataset.search_base(alt_base))
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

        # Filters by regexp
        #
        # @example
        #   relation.grep(sn: /regexp/)
        #
        # @return [Relation]
        #
        # def grep(options)
        #   new(
        #     dataset.map do |e|
        #       attribute = options.keys.first
        #       regexp    = options.values.first
        #       e[attribute].grep(regex)
        #     end
        #   )
        # .detect {|f| f["age"] > 35 }
        # end

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
