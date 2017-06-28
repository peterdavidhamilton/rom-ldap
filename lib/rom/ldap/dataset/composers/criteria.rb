require 'facets/hash/deep_merge'
require 'rom/ldap/dataset/composers/filter'

module ROM
  module Ldap
    module Dataset
      module Composers
        class Criteria

          attr_reader :api
          attr_reader :criteria
          attr_reader :filter_composer

          def initialize(api)
            @api = api
            @criteria ||= { conditions: {} }
            @filter_composer = Composers::Filter.new
          end

          private :api
          private :criteria
          private :filter_composer

          def build(args, &block)
            criteria[:conditions].deep_merge!({"_#{__callee__}" => args})
            self
          end

          # private :build

          # dynamically generate methods an Ldap::Relation#dataset
          # can respond to which are available in the FilterComposer
          #
          Composers::Filter.query_methods.each do |m|
            alias_method m, :build
          end

          def order(value)
            criteria[:order] = value
            self
          end

          def limit(limit)
            criteria[:limit] = limit
            self
          end

          def reverse
            criteria[:reverse] = true
            self
          end

          def each(&block)
            results = search

            return results unless block_given?

            if criteria[:limit]
              results = results.take(criteria[:limit])

            elsif criteria[:order]
              results = results.sort_by { |entry| entry[criteria[:order]] }

            elsif criteria[:reverse]
              results = results.reverse
            end

            @criteria = { conditions: {} }
            results.each(&block)
          end

          def to_a
            each.to_a
          end

          def to_filter
            filter_composer.call(criteria[:conditions])
          end

          def inspect
            "#<#{self.class.name}:#{self.object_id} #{criteria.inspect}>"
          end

          def search
            api.search(to_filter)
          end

          private :search
        end


      end
    end
  end
end
