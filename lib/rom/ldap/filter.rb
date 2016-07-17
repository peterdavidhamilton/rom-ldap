module ROM
  module Ldap
    class Relation < ROM::Relation
      class Filter
        class FilterError < ::StandardError; end

        extend Uber::Delegates

        delegates Net::LDAP::Filter, :begins,
                                     :construct,
                                     :contains,
                                     :ends,
                                     :escape,
                                     :equals,
                                     :equals,
                                     :ge,
                                     :le,
                                     :negate,
                                     :present

        def chain(args)
          filters = args.each_with_object([]) do |(method, params), obj|
            obj << send(method, params)
          end
          _join filters.join
        end

        def _join(filters)
          construct "(&#{filters})"
        end

        def _intersect(filters)
          construct "(|#{filters})"
        end

        def where(args)
          _join generate(:equals, args)
        end

        alias :filter :where

        def match(args)
          _intersect generate(:contains, args)
        end

        def with_attribute(arg)
          _join generate(:present, arg)
        end

        def not(args)
          negate where(args)
        end

        def exclude(args)
          negate match(args)
        end

        # TODO: match_all match_any
        # TODO: search ranges lt and gt etc
        def within(range)
          upper = range.to_a.last
          upper = range.to_a.first
        end

        alias :between :within

        def above(args)
          _join generate(:ge, args)
        end

        alias :gte :above

        def below(args)
          _join generate(:le, args)
        end

        alias :lte :below

        def prefix
          _join generate(:begins, args)
        end

        def suffix
          _join generate(:ends, args)
        end

        def generate(type, args, stash = [])
          if args.respond_to?(:each)
            args.each do |attribute, values|
              next if values.nil?
              case values
              when Array
                values.each { |value| stash << send(type, attribute, escape(value)) }
              else
                stash << send(type, attribute, escape(values))
              end
            end
          else
            stash << send(type, args)
          end

          msg = 'Relation::Filter#generate received no valid arguments'
          fail FilterError, msg if stash.none?

          stash.one? ? stash.first : stash.join
        end
      end
    end
  end
end
