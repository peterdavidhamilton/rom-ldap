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
        def with_base(alt_base)
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


        # Remove additional search criteria and return to initial filter.
        #
        # @return [Relation]
        #
        # @api public
        def unfiltered
          new(dataset.with(criteria: EMPTY_ARRAY))
        end

        # Replace the relation filter with a new query.
        #
        # @param new_filter [String] Valid LDAP filter string
        #
        # @return [Relation]
        #
        # @api public
        def search(new_filter)
          new(dataset.with(name: new_filter))
        end

        # Returns True if the filtered entity can bind.
        #
        # @return [Boolean]
        #
        # @api public
        def authenticate(password)
          dataset.bind(password)
        end

        # Map tuples from the relation
        #
        # @example
        #   users.map { |user| user[:id] }
        #   # =>  [1, 2, 3]
        #
        #   users.map(:id).to_a
        #   # =>  [1, 2, 3]
        #
        # @param key [Symbol] An optional name of the key for extracting values
        #                     from tuples
        #
        # @return [Array<Array>]
        #
        # @api public
        def map(key = nil, &block)
          dataset.map(key, &block)
        end

        # Array of values for an :attribute from all tuples.
        #
        # @param field [Symbol] formatted or canonical attribute key
        #
        # @example
        #   relation.by_sn('Hamilton').list(:given_name)
        #
        # @return [Array<Mixed>]
        #
        # @raise [ROM::Struct::MissingAttribute] If auto_struct? and field not present.
        #
        # @api public
        def list(field)
          if auto_struct?
            to_a.flat_map(&field)
          else
            map(field).to_a.compact.flatten
          end
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

        # Find tuples by primary_key which defaults to :entry_dn
        # Method is required by commands.
        #
        # @param pks [Integer, String] single values
        #
        # @example
        #   relation.by_pk(1001, 1002)
        #   relation.by_pk('uid=test1,ou=users,dc=example,dc=com')
        #
        # @return [Relation]
        def by_pk(*pks)
          where(primary_key => pks)
        end

        # Fetch a tuple identified by the pk
        #
        # @param pk [String, Integer]
        #
        # @example
        #   users.fetch(1001) # => {:id => 1, name: "Peter"}
        #
        # @return [Hash]
        #
        # @raise [ROM::TupleCountMismatchError] When 0 or more than 1 tuples were found
        #
        # @api public
        def fetch(*pk)
          by_pk(*pk).one!
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

        # Use server-side sorting if available.
        #
        # Orders the dataset by a given attribute using the coerced value.
        #
        # @see https://tools.ietf.org/html/rfc2891
        #
        # SortResult ::= SEQUENCE {
        #     sortResult  ENUMERATED {
        #        success                   (0), -- results are sorted
        #        operationsError           (1), -- server internal failure
        #        timeLimitExceeded         (3), -- timelimit reached before
        #                                       -- sorting was completed
        #        strongAuthRequired        (8), -- refused to return sorted
        #                                       -- results via insecure
        #                                       -- protocol
        #        adminLimitExceeded       (11), -- too many matching entries
        #                                       -- for the server to sort
        #        noSuchAttribute          (16), -- unrecognized attribute
        #                                       -- type in sort key
        #        inappropriateMatching    (18), -- unrecognized or inappro-
        #                                       -- priate matching rule in
        #                                       -- sort key
        #        insufficientAccessRights (50), -- refused to return sorted
        #                                       -- results to this client
        #        busy                     (51), -- too busy to process
        #        unwillingToPerform       (53), -- unable to sort
        #        other                    (80)
        #        },
        #     attributeType [0] AttributeType OPTIONAL }
        #
        # @param attribute [Symbol]
        #
        # @example
        #   relation.order(:uid_number).to_a =>
        #     [
        #       {uid_number: 101},
        #       {uid_number: 202},
        #       {uid_number: 303}
        #     ]
        #
        # @return [Relation]
        #
        # @api public
        def order(*attribute)
          new(dataset.with(sort_attrs: attribute))

          # Move this inside the Dataset so it is always a Dataset class never an Array
          # if dataset.directory.sortable?
          #   new(dataset.with(sort_attrs: dataset.map_attribute(attribute)))
          # else
          #   new(dataset.sort_by { |tuple| output_schema[tuple][attribute] || EMPTY_ARRAY })
          # end
        end

        # Reverses the dataset.
        # Use server-side sorting if available.
        #
        # @example
        #   relation.reverse
        #
        # @return [Relation]
        #
        # @api public
        def reverse
          new(dataset.with(direction: :desc))
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
          new(dataset.with(limit: number))
        end

        # Shuffles the dataset.
        #
        # @example
        #   relation.random
        #
        # @return [Relation]
        #
        # @api public
        def random
          # new(dataset.sort_by { rand })
          new(dataset.with(rand: true))
        end

        # Searches attributes of the projected schema for a match.
        #
        # @param value [String]
        #
        # @return [Relation]
        #
        # @example
        #   relation.find('eo')
        #
        # @api public
        def find(value)
          new(dataset.grep(schema.map(&:name).sort, value))
        end

        # A Hash argument is passed straight to Dataset#equal.
        # Otherwise the RestrictionDSL builds abstract queries
        #
        # @param args [Array<Array, Hash>] AST queries or an attr/val hash.
        #
        #
        # @example
        #   users.where { id.is(1)  }
        #   users.where { id == 1   }
        #   users.where { id > 1    }
        #   users.where { id.gte(1) }
        #
        #   users.where(users[:id].is(1))
        #   users.where(users[:id].lt(1))
        #
        # @api public
        def where(*args, &block)
          if block
            where(args).where(schema.restriction(&block))
          elsif args.size == 1 && args[0].is_a?(Hash)
            new(dataset.equal(args[0]))
          elsif !args.empty?
            new(dataset.join(args))
          else
            self
          end
        end


        # List values of the "member" attribute for a group.
        #
        # @param [String] dn Distinguished name.
        #
        # @return [Array<String>]
        #
        # @api public
        def members_of_group(dn)
          with(auto_struct: false).by_pk(dn).list(:member)
        end


        # Requires attribute to respond to #qualified
        #
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

      end
    end
  end
end
