require 'rom/ldap/filter/builder'

module ROM
  module LDAP
    module Filter
      class DSL
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
          internals.map { |m| m.to_s.tr('_', '').to_sym }
        end


        # forward(*Builder::METHODS)

        # def self.forward
        #   Builder::METHODS.each do |method|
        #     class_eval <<-RUBY, __FILE__, __LINE__ + 1
        #       def #{method}(*args, &block)
        #         Builder.__send__(:#{method}, *args, &block)
        #       end
        #     RUBY
        #   end
        # end


                def begins(*args)
                  Builder.begins(*args)
                end

                def contains(*args)
                  Builder.contains(*args)
                end

                def ends(*args)
                  Builder.ends(*args)
                end

                def escape(*args)
                  Builder.escape(*args)
                end

                def equals(*args)
                  Builder.equals(*args)
                end

                def ge(*args)
                  Builder.ge(*args)
                end

                def le(*args)
                  Builder.le(*args)
                end

                def equals(*args)
                  Builder.equals(*args)
                end

                def present?(*args)
                  # Builder.present(*args)
                  Builder.new(:eq, attribute, WILDCARD)
                end

                alias present present?
                alias pres present?

                def negate(filter)
                  # Builder.negate(*args)
                  Builder.new(:not, filter, nil)
                end


                # Uses the folowwing builder class methods  => eq ne le ge ex
                def construct(ldap_filter_string)
                  Filter::Parser.new(Filter::Builder).call(ldap_filter_string)
                end



        # @return [String]
        #
        # @param params [Array] Chained criteria build by dataset
        #
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

        alias [] call

        #
        # Fields
        #
        def _equals(args)
          g(:equals, args)
        end

        alias _where _equals

        def _unequals(args)
          Builder.negate(_equals(args))
        end

        #
        # Attrs
        #
        def _present(arg)
          g(:present, arg)
        end

        alias _has _present
        alias _exists _present

        def _missing(args)
          Builder.negate(_present(args))
        end

        alias _hasnt _missing

        #
        # Strings
        #
        def _begins(args)
          g(:begins, args)
        end

        alias _prefix _begins

        def _ends(args)
          g(:ends, args)
        end

        alias _suffix _ends

        def _contains(args)
          g(:contains, args)
        end

        alias _matches _contains

        def _exclude(args)
          Builder.negate(_contains(args))
        end

        #
        # Range
        #
        def _within(args)
          args.map do |attribute, range|
            bottom = range.to_a.first
            top = range.to_a.last
            lower       = _gte(attribute => bottom)
            upper       = _lte(attribute => top)
            _and(lower, upper)
          end
        end

        alias _between _within
        alias _range _within

        def _outside(args)
          Builder.negate(_within(args))
        end

        #
        # Numeric
        #
        def _gte(args)
          g(:ge, args)
        end

        alias _above _gte

        def _lte(args)
          g(:le, args)
        end

        alias _below _lte

        private

        # union
        #
        def _and(*filters)
          # Builder.construct("(&#{filters.join})")
          construct("(&#{filters.join})")
        end

        # intersection
        #
        def _or(*filters)
          # Builder.construct("(|#{filters.join})")
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

        def submit(method, attribute, value = nil)
          if value
            send(method, attribute, Types::Coercible::String[value])
          else
            send(method, attribute)
          end
        end
      end
    end
  end
end
