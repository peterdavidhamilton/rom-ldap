# encoding: utf-8
# frozen_string_literal: true

require 'rom/ldap/constants'

module ROM
  module Ldap
    class Relation < ROM::Relation
      module Reading
        def self.included(klass)
          # @return Dataset
          #
          # @api public
          def filter(args)
            filter = Filter.new.send(__callee__, args)
            new(search(filter))
          end

          klass.class_eval do
            FILTERS.each { |f| alias_method f, :filter }
          end
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

        # @return Array
        #
        # @api public
        def order(attribute)
          new(dataset.sort { |p1, p2| p1[attribute] <=> p2[attribute] })
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
