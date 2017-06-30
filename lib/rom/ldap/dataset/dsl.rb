#
# http://www.rubydoc.info/gems/ruby-net-ldap/Net/LDAP/Filter
#
# method     | aliases          | RFC-2254 filter string
# ______________________________________________________________________
# :filter    |                  |
# :present   | :has, :exists    | 'column=*'
# :lte       | :below,          | 'column<=value'
# :gte       | :above,          | 'column>=value'
# :begins    | :prefix,         | 'column=value*'
# :ends      | :suffix,         | 'column=*value'
# :within    | :between, :range | '&(('column>=value')('column<=value'))'
# :outside   |                  | '~&(('column>=value')('column<=value'))'
# :equals    | :where,          | 'column=value'
# :not       | :missing,        | '~column=value'
# :contains  | :matches,        | 'column=*value*'
# :excludes  |                  | '~column=*value*'
#

require 'forwardable'

module ROM
  module Ldap
    class Dataset
      class DSL
        DSLError = Class.new(StandardError)

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
        def [](args)
          filters = args.each_with_object([]) do |(command, params), array|
            array << submit(command, params)
          end

          _and(filters)
        end


        # Parses raw ldap_filter_string
        #
        # @example
        #   ROM.container(config).relations[:ninjas].filter('uid=*est*')
        #
        # @return [Net::LDAP::Filter]
        #
        def _filter(args)
          unless args.is_a?(String)
            raise DSLError, '#filter requires an ldap_filter_string'
          else
            construct(args)
          end
        end


        #
        # Fields
        #
        def _equals(args)
          g(:equals, args)
        end

        alias_method :_where, :_equals

        def _not(args)
          negate(_equals(args))
        end

        alias_method :_missing, :_not

        def _present(arg)
          g(:present, arg)
        end

        alias_method :_has,    :_present
        alias_method :_exists, :_present



        #
        # Strings
        #
        def _begins(args)
          g(:begins, args)
        end

        alias_method :_prefix, :_begins

        def _ends(args)
          g(:ends, args)
        end

        alias_method :_suffix, :_ends

        def _contains(args)
          g(:contains, args)
        end

        alias_method :_matches, :_contains

        def _excludes(args)
          negate(_contains(args))
        end


        #
        # Range
        #
        def _within(args)
          args.map do |attribute, range|
            bottom, top = range.to_a.first, range.to_a.last
            lower       = _gte(attribute => bottom)
            upper       = _lte(attribute => top)
            _and(lower, upper)
          end
        end

        alias_method :_between, :_within
        alias_method :_range,   :_within

        def _outside(args)
          negate(_within(args))
        end


        #
        # Numeric
        #
        def _gte(args)
          g(:ge, args)
        end

        alias_method :_above, :_gte

        def _lte(args)
          g(:le, args)
        end

        alias_method :_below, :_lte



        private

        # intersection
        #
        def _and(*filters)
          construct("(&#{filters.join})")
        end

        # union
        #
        def _or(*filters)
          construct("(|#{filters.join})")
        end


        def g(command, params)
          collection = []

          if params.is_a?(Hash)
            params.each do |attribute, values|
              attribute_store = []

              [values].flatten.compact.each do |value|
                attribute_store << submit(command, attribute, value)
              end

              collection << _or(attribute_store)
            end

          else
            collection << submit(command, params)
          end

          if collection.none?
            raise DSLError, '#g (generate) did not receive any valid arguments'
          else
            _and(collection)
          end
        end

        # delegate to Net::LDAP::Filter
        # coerce any value to a string
        #
        def submit(method, attribute, value=nil)
          if value
            send(method, attribute, Types::Input[value])
          else
            send(method, attribute)
          end
        end
      end

    end
  end
end
