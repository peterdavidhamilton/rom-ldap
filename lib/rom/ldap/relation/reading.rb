module ROM
  module LDAP
    class Relation < ROM::Relation
      module Reading

        # Specify an alternative search base.
        #
        # @example
        #   relation.with_base("cn=department,ou=users,dc=org")
        #
        # @return [Relation] Defaults to class attribute
        #
        # @api public
        def with_base(alt_base = self.class.base)
          new(dataset.with(base: alt_base))
        end

        # Change the search base to search the whole directory tree.
        #
        # @example
        #   relation.whole_tree
        #
        # @return [Relation]
        #
        # @api public
        def whole_tree
          with_base(EMPTY_STRING)
        end

        # An alternative search base selected from a class level hash.
        #
        # @param key [Symbol]
        #
        # @example
        #   Relation.branches { custom: '(attribute=value)' }
        #
        #   relation.branch(:custom)
        #
        # @api public
        def branch(key)
          with_base(self.class.branches[key])
        end

        # Standard directory query. Supersede criteria with the given filter string.
        #
        # @param filter [String] Valid LDAP filter string
        #
        # @return [Relation]
        #
        # @api public
        def search(filter)
          new(dataset.with(base: self.class.base, filter: filter))
        end

        # Returns True if the filtered entity can bind.
        #
        # @return [Boolean]
        #
        # @api public
        def authenticate(password)
          dataset.bind(password)
        end

        # Count the number of entries selected from the paginated dataset.
        #
        # @return [Integer]
        #
        # @api public
        def count
          dataset.__send__(__method__)
        end

        # Count the number of entries in the dataset.
        #   Unrestricted by the gateway search limit.
        #
        # @return [Integer]
        #
        # @api public
        def total
          dataset.__send__(__method__)
        end

        # @return [Boolean]
        #
        # @api public
        def one?
          dataset.__send__(__method__)
        end
        alias distinct? one?
        alias unique? one?

        # @return [Boolean]
        #
        # @api public
        def any?(&block)
          dataset.__send__(__method__, &block)
        end
        alias exist? any?

        # @return [Boolean]
        #
        # @api public
        def none?(&block)
          dataset.__send__(__method__, &block)
        end

        # @return [Boolean]
        #
        # @api public
        def all?(&block)
          dataset.__send__(__method__, &block)
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

        # TODO: server-side sorting https://tools.ietf.org/html/rfc2891
        #
        # Orders the dataset by a given attribute using the coerced value.
        #   Numeric attributes should appear in increasing order.
        #
        # @param attribute [Symbol]
        #
        # @example
        #   relation.order(:uid_number) => 101, 202, 303
        #
        # @return [Relation]
        #
        # @api public
        def order(attribute)
          # if dataset.directory.sortable?
          #   binding.pry
          #   new(dataset)
          # else
            new(dataset.sort_by { |tuple| output_schema[tuple][attribute] })
          # end

          # new(dataset.with(entries: dataset.sort_by { |tuple| output_schema[tuple][attribute] })
        end

        # Limits the dataset to a number of tuples
        #
        # @todo prevents option to export as dataset is now an array
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
          new(dataset.sort_by { rand })
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


        # Lists a single attribute from each tuple sorted
        #
        # @example
        #   relation.by_sn('Hamilton').list(:given_name)
        #
        # @return [Array<Mixed>]
        #
        # @api public
        def list(field)
          if auto_struct?
            project(field).to_a.flat_map(&field).sort
          else
            project(field).to_a.map { |t| t[field] }.sort
          end
        end



        # Restrict a relation to match criteria
        #
        # @overload where(conditions)
        #   Restrict a relation using a hash with conditions
        #
        #   @example
        #     users.where(name: 'Jane', age: 30)
        #
        #   @param [Hash] conditions A hash with conditions
        #
        # @overload where(conditions, &block)
        #   Restrict a relation using a hash with conditions and restriction DSL
        #
        #   @example
        #     users.where(name: 'Jane') { age > 18 }
        #
        #   @param [Hash] conditions A hash with conditions
        #
        # @overload where(&block)
        #   Restrict a relation using restriction DSL
        #
        #   @example
        #     users.where { age > 18 }
        #     users.where { (id < 10) | (id > 20) }
        #
        # @return [Relation]
        #
        # @api public
        # def where(*args, &block)
        #    if block
        #      where(*args).where(schema.canonical.restriction(&block))
        #    elsif args.size == 1 && args[0].is_a?(Hash)
        #      new(dataset.where(coerce_conditions(args[0])))
        #    elsif !args.empty?
        #      new(dataset.where(*args))
        #    else
        #      self
        #    end
        #  end

        # Filters entities by pattern against canonical hash.
        #
        # @see Directory::Entry.to_str
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
        # @return [Relation]
        #
        # @api public
        def qualified
          schema.qualified.call(self)
        end

        # Map tuples from the relation
        #
        # @example
        #   users.map { |user| user[:id] }
        #   # [1, 2, 3]
        #
        #   users.map(:id).to_a
        #   # [1, 2, 3]
        #
        # @param key [Symbol] An optional name of the key for extracting values
        #                     from tuples
        #
        # @api public
        def map(key = nil, &block)
          dataset.map(key, &block)
        end

        #
        # Associations
        #
        #

        # @example
        #   join(:accounts, id: :uid_number)
        #
        def join(other, join_cond = EMPTY_HASH)
          # binding.pry

          if other.is_a?(Symbol) || other.is_a?(ROM::Relation::Name)
            if join_cond.empty?
              # ROM::LDAP::Associations::ManyToOne
              associations[other].join(self)
              # else
              # new(dataset.__send__(type, other.to_sym, join_cond, opts, &block))
            end
          # elsif other.is_a?(Sequel::SQL::AliasedExpression)
          #   new(dataset.__send__(type, other, join_cond, opts, &block))
          # elsif other.respond_to?(:name) && other.name.is_a?(Relation::Name)
          #   associations[other.name.key].join(type, self, other)
          else
            raise ArgumentError, "+other+ must be either a symbol or a relation, #{other.class} given"
          end
        end
      end
    end
  end
end
