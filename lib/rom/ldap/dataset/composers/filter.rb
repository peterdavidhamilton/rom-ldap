require 'forwardable'
#
# delegate to Net::LDAP::Filter in order to chain
#
module ROM
  module Ldap
    module Dataset
      module Composers
        class Filter
          FilterError = Class.new(StandardError)

          # List all public methods that are NOT forwarded to Net::LDAP::Filter
          # These should be aliased to Lookup#build
          # underscore nomenclature prevents clash with Net::LDAP::Filter methods.
          #
          def self.internals
            new.public_methods.select { |m| /^_[a-z]+$/.match?(m) }
          end

          def self.query_methods
            internals.map { |m| m.to_s.tr('_','').to_sym }
          end

          extend Forwardable

          delegate [
                    :begins,
                    :construct,
                    :contains,
                    :ends,
                    :escape,
                    :equals,
                    :ge,
                    :le,
                    :negate,
                    :present
                    ] => Net::LDAP::Filter

          # @return Net::LDAP::Filter
          #
          def call(args)
            # parse raw ldap_filter_string
            return construct(args) if args.is_a?(String)

            # build array of filters
            filters = args.each_with_object([]) do |(command, params), obj|
              obj << send(command, params)
            end

            # merge filter
            _and(filters.join)
          end


          #
          # Fields
          #
          def _where(args)
            _and(generate(:equals, args))
          end

          alias_method :_filter, :_where

          def _present(arg)
            _and(generate(:present, arg))
          end

          alias_method :_has, :_present
          alias_method :_exist, :_present

          def _not(args)
            negate(_where(args))
          end



          #
          # Strings
          #
          def _begins(args)
            _and(generate(:begins, args))
          end

          alias_method :_prefix, :_begins
          alias_method :_starts_with, :_begins

          def _ends(args)
            _and(generate(:ends, args))
          end

          alias_method :_suffix, :_ends
          alias_method :_ends_with, :_ends

          def _contains(args)
            _and(generate(:contains, args))
          end

          alias_method :_match, :_contains

          def _excludes(args)
            negate(_contains(args))
          end


          #
          # Range
          #
          def _within(range)
            lower, upper = range.to_a.first, range.to_a.last
            # TODO: Dataset::Composers::Filter#_within
          end

          alias_method :_between, :_within
          alias_method :_range, :_within


          #
          # Numeric
          #
          def _gte(args)
            _and(generate(:ge, args))
          end

          alias_method :_above, :_gte

          def _lte(args)
            _and(generate(:le, args))
          end

          alias_method :_below, :_lte



          private

          def _and(filters)
            construct("(&#{filters})")
          end

          def _or(filters)
            construct("(|#{filters})")
          end


          def generate(command, params)
            collection = []

            if params.is_a?(Hash)
              params.each do |attribute, values|
                attribute_store = []

                [values].flatten.compact.each do |value|
                  attribute_store << submit(command, attribute, value)
                end

                collection << _or(attribute_store.join)
              end

            else
              collection << submit(command, params)
            end

            if collection.none?
              raise FilterError, 'Dataset::Composers::Filter#generate no valid arguments'
            else
              collection.join
            end
          end


          def submit(method, attribute, value)
            # puts "submitting ##{method}(#{attribute}, #{value})"
            send(method, attribute, Types::Input[value])
          end

        end
      end
    end
  end
end
