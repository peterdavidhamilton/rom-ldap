# avg
# distinct
# exclude
# exist?
# fetch
# first
# group
# group_and_count
# group_append
# having
# inner_join
# invert
# join
# last
# left_join
# limit
# lock
# map
# max
# min
# offset
# order
# pluck
# prefix
# project
# qualified
# qualified_columns
# read
# rename
# reverse
# right_join
# select_append
# select_group
# sum
# union
# unt
# where

module ROM
  module LDAP
    class Relation < ROM::Relation
      module Reading

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

        # @return [Boolean]
        #
        # @api public
        #
        def any?
          dataset.any?
        end

        # @return [Boolean]
        #
        # @api public
        #
        def none?
          dataset.none?
        end

        # Find tuple by primary_key - required by commands
        #
        # Selects on certain attributes from tuples
        #
        # @example
        #   ROM.container(config).relations[:ninjas].fetch(1001)
        #
        # @return [Relation]
        #
        def by_pk(pk)
          where(primary_key => pk)
        end

        alias_method :fetch, :by_pk

        # First tuple from dataset
        #
        # @example
        #   ROM.container(config).relations[:ninjas].where(sn: 'smith').first
        #
        # @return [Relation]
        #
        def first
          new([dataset.take(1)])
        end

        # Last tuple from dataset
        #
        # @example
        #   ROM.container(config).relations[:ninjas].where(sn: 'smith').last
        #
        # @return [Relation]
        #
        def last
          new([dataset.reverse_each.take(1)])
        end

        # Orders the dataset by a given attribute
        #
        # @example
        #   ROM.container(config).relations[:ninjas].order(:givenname)
        #
        # @return [Relation]
        #
        def order(attribute)
          new(dataset.sort_by { |e| e[attribute] })
        end

        # Limits the dataset to a number of tuples
        #
        # @example
        #   ROM.container(config).relations[:ninjas].limit(6)
        #
        # @return [Relation]
        #
        def limit(number)
          new(dataset.take(number))
        end

        # Shuffles the dataset
        #
        # @example
        #   ROM.container(config).relations[:ninjas].random
        #
        # @return [Relation]
        #
        def random
          new(dataset.entries.shuffle)
        end

        # Reverses the dataset
        #
        # @example
        #   ROM.container(config).relations[:ninjas].reverse
        #
        # @return [Relation]
        #
        def reverse
          new(dataset.reverse_each.entries)
        end

        # Selects on certain attributes from tuples
        #
        # @example
        #   ROM.container(config).relations[:ninjas].where(sn: 'smith').select(:dn, :sn, :uid)
        #
        # @return [Relation]
        #
        def select(*args)
          new(dataset.map { |e| e.select { |k,v| args.include?(k) } })
        end

        # Filters by regexp
        #
        # @example
        #   ROM.container(config).relations[:ninjas].grep(sn: /regexp/)
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
      end
    end
  end
end
