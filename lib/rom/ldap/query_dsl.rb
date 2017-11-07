require 'rom/ldap/filter/builder'

module ROM
  module LDAP
    class QueryDSL
      DSLError = Class.new(StandardError)

      # Public instance methods prefixed with underscore
      #
      # @return [Array <String>]
      # @api private
      #
      def self.internals
        new.public_methods.select { |m| /^_[a-z]+$/.match?(m) }
      end

      # Coerce and expose public DSL query methods
      #   '_exclude' to :exclude
      #
      # @example
      #   ROM::LDAP::Dataset.query_methods
      #     => [:unequals, :equals, :present, :missing]
      #
      # @return [Array<Symbol>]
      #
      # @api public
      def self.query_methods
        internals.map { |m| m.to_s.tr('_','').to_sym }
      end


      def begins(*args)
        Filter::Builder.begins(*args)
      end

      def contains(*args)
        Filter::Builder.contains(*args)
      end

      def ends(*args)
        Filter::Builder.ends(*args)
      end

      def escape(*args)
        Filter::Builder.escape(*args)
      end

      def equals(*args)
        Filter::Builder.equals(*args)
      end

      def ge(*args)
        Filter::Builder.ge(*args)
      end

      def le(*args)
        Filter::Builder.le(*args)
      end

      def equals(*args)
        Filter::Builder.equals(*args)
      end

      def present(*args)
        Filter::Builder.present(*args)
      end

      # @return [String]
      #
      # @param params [Array] Chained criteria build by dataset
      # @param original [Array] Starting table name for relation schema
      #
      # @api public
      def call(params, original)
        filters = [original]

        if params.is_a?(String)
          filters << params
        else
          params.each { |cmd, args| filters << submit(cmd, args) }
        end

        _and(filters).to_s # TODO: add OR join using DSL

        rescue => e
          raise e
          original
      end

      alias_method :[], :call

      #
      # Fields
      #
      def _equals(args)
        g(:equals, args)
      end

      alias_method :_where, :_equals

      def _unequals(args)
        Filter::Builder.negate(_equals(args))
      end


      #
      # Attrs
      #
      def _present(arg)
        g(:present, arg)
      end

      alias_method :_has,    :_present
      alias_method :_exists, :_present

      def _missing(args)
        Filter::Builder.negate(_present(args))
      end

      alias_method :_hasnt, :_missing



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

      def _exclude(args)
        Filter::Builder.negate(_contains(args))
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
        Filter::Builder.negate(_within(args))
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

      # union
      #
      def _and(*filters)
        Filter::Builder.construct("(&#{filters.join})")
      end

      # intersection
      #
      def _or(*filters)
        Filter::Builder.construct("(|#{filters.join})")
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

      # delegate to ROM::LDAP::Dataset::FilterDSL
      # coerce any value to a string
      #
      def submit(method, attribute, value=nil)
        if value
          send(method, attribute, Types::Coercible::String[value])
        else
          send(method, attribute)
        end
      end
    end

  end
end
