# avg
# group
# group_and_count
# group_append
# having
# inner_join
# invert
# join
# left_join
# lock
# map
# max
# min
# offset
# prefix
# project
# qualified
# qualified_columns
# read
# rename
# right_join
# select_append
# select_group
# sum
# union
# unt

module ROM
  module LDAP
    class Relation < ROM::Relation
      module Reading

        # Returns empty dataset if the filtered entity cannot bind.
        #
        # @return [Relation]
        #
        # @api public
        #
        def authenticate(password)
          if dataset.authenticated?(password)
            new(dataset)
          else
            new([])
          end
        end

        # Returns True if the filtered entity can bind.
        #
        # @return [Boolean]
        #
        # @api public
        #
        def authenticated?(password)
          !!dataset.authenticated?(password)
        end

        # @return [Integer]
        #
        # @api public
        #
        def count
          dataset.count
        end

        # @return [Boolean]
        #
        # @api public
        #
        def unique?
          dataset.one?
        end

        alias_method :distinct?, :unique?

        # @return [Boolean]
        #
        # @api public
        #
        def exist?
          dataset.exist?
        end

        alias_method :any?, :exist?

        # @return [Boolean]
        #
        # @api public
        #
        def none?
          !exist?
        end

        # Find tuple by primary_key - required by commands
        #
        # Selects on certain attributes from tuples
        #
        # @example
        #   relation.by_pk(1001)
        #
        # @return [Relation]
        #
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
        # @api public
        #
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
        def first
          dataset.take(1)
        end

        # Last tuple from the relation
        #
        # @example
        #   relation.where(sn: 'smith').last
        #
        # @return [Hash]
        #
        def last
          dataset.reverse_each.take(1)
        end

        # Orders the dataset by a given attribute
        #
        # @example
        #   relation.order(:givenname)
        #
        # @return [Relation]
        #
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
        def reverse
          new(dataset.reverse_each.entries)
        end

        # Selects on certain attributes from tuples
        #
        # @example
        #   relation.where(sn: 'smith').select(:dn, :sn, :uid)
        #
        # @return [Relation]
        #
        def select(*args)
          new(dataset.map { |e| e.select { |k,v| args.include?(k) } })
        end

        alias_method :pluck, :select


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
          schema.qualified.(self)
        end

        def join(*args)
          binding.pry
        end
      end
    end
  end
end
