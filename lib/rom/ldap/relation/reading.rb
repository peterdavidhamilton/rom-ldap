module ROM
  module Ldap
    class Relation < ROM::Relation
      module Reading
        # @return Array
        #
        # @api public
        def order(attribute)
          new(dataset.sort { |p1, p2| p1[attribute] <=> p2[attribute] })
        end

        # @return Integer
        #
        # @api public
        def count
          dataset.size
        end

        # @return Boolean
        #
        # @api public
        def unique?
          dataset.one?
        end

        # @return Boolean
        #
        # @api public
        def any?
          !dataset.empty?
        end

        # @return Boolean
        #
        # @api public
        def none?
          dataset.none?
        end

        # @return Array
        #
        # @api public
        def first
          new(dataset.first)
        end

        # @return Array
        #
        # @api public
        def last
          new(dataset.last)
        end

        # @return Array
        #
        # @api public
        def limit(number)
          new(dataset.take(number))
        end

        # @return Array
        #
        # @api public
        def random
          new(dataset.shuffle)
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
          schema.qualified.(self)
        end
      end
    end
  end
end
