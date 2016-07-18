# encoding: utf-8
# frozen_string_literal: true

module ROM
  module Ldap
    class Relation < ROM::Relation
      module Reading

        # int
        def count
          dataset.size
        end

        # bool
        def unique?
          dataset.one?
        end

        # bool
        def any?
          !dataset.empty?
        end

        # bool
        def none?
          dataset.none?
        end

        # []
        def first
          __new__(dataset.first)
        end

        # []
        def last
          __new__(dataset.last)
        end

        # []
        def order(attribute)
          sorted = dataset.sort do |p1, p2|
            p1[attribute] <=> p2[attribute]
          end
          __new__(sorted)
        end

      end
    end
  end
end
