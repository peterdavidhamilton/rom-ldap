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

        # Called by changeset
        #
        # @api private
        def fetch(dn)
          where(dn: dn)
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
          # __new__(dataset.first) # 'new' not '__new__' in module
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
        def order(attribute)
          sorted = dataset.sort { |p1, p2| p1[attribute] <=> p2[attribute] }
          new(sorted)
        end

      end
    end
  end
end
