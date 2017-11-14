require 'rom/ldap/filter/parser'     # #construct
require 'rom/ldap/filter/expression' # #build

module ROM
  module LDAP
    module Filter
      class DSL
        DSLError = Class.new(StandardError)


        ESCAPES = {
          "\0" => '00', # NUL      = %x00 ; null character
          '*'  => '2A', # ASTERISK = %x2A ; asterisk (WILDCARD)
          '('  => '28', # LPARENS  = %x28 ; left parenthesis ("(")
          ')'  => '29', # RPARENS  = %x29 ; right parenthesis (")")
          '\\' => '5C', # ESC      = %x5C ; esc (or backslash) ("\")
        }.freeze

        ESCAPE_REGEX = Regexp.new('[' + ESCAPES.keys.map { |e| Regexp.escape(e) }.join + ']')



        # Public instance methods prefixed with underscore
        #
        # @return [Array <String>]
        # @api private
        #
        # def self.internals
        #   new.public_methods.select { |m| /^_[a-z]+$/.match?(m) }
        # end

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
        # def self.query_methods
        #   internals.map { |m| m.to_s.tr('_', '').to_sym }
        # end


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
            binding.pry
            # {"_equals"=>{:uid=>"billy"}}
            # [:eq, :uid, 'billy']
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
        # def _equals(args)
        #   g(:equals, args)
        # end

        # alias _where _equals

        # def _unequals(args)
        #   negate(_equals(args))
        # end

        #
        # Attrs
        #
        def _present(arg)
          g(:present, arg)
        end

        alias _has _present
        alias _exists _present

        def _missing(args)
          negate(_present(args))
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
          negate(_contains(args))
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
          negate(_within(args))
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
          construct("(&#{filters.join})")
        end

        # intersection
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

        def submit(method, attribute, value = nil)
          if value
            send(method, attribute, Types::Coercible::String[value])
          else
            send(method, attribute)
          end
        end




        def equals(attribute, value)
          build(:eq, attribute, escape(value))
        end

        def begins(attribute, value)
          build(:eq, attribute, escape(value) + WILDCARD)
        end

        def ends(attribute, value)
          build(:eq, attribute, WILDCARD + escape(value))
        end

        def contains(attribute, value)
          build(:eq, attribute, WILDCARD + escape(value) + WILDCARD)
        end

        def bineq(attribute, value)
          build(:bineq, attribute, value)
        end

        def ex(attribute, value)
          build(:ex, attribute, value)
        end

        def ne(attribute, value)
          build(:ne, attribute, value)
        end

        def ge(attribute, value)
          build(:ge, attribute, value)
        end

        def le(attribute, value)
          build(:le, attribute, value)
        end

        def present?(attribute)
          build(:eq, attribute, WILDCARD)
        end

        alias present present?
        alias pres present?

        def negate(filter)
          build(:not, filter, nil)
        end


        def construct(filter)
          Parser.new.call(filter)
        end



        # def parse_ldap_filter(obj)
        #   case obj.ber_identifier
        #   when 0x87 then Builder.new(:eq, obj.to_s, WILDCARD) # present. context-specific primitive 7.
        #   when 0xa3 then Builder.new(:eq, obj[0], obj[1])     # equalityMatch. context-specific constructed 3.
        #   else
        #     raise FilterError, "Unknown LDAP search-filter type: #{obj.ber_identifier}"
        #   end
        # end



        def escape(string)
          string.gsub(ESCAPE_REGEX) { |char| '\\' + ESCAPES[char] }
        end

        def build(*args)
          Expression.new(*args)
        end

      end
    end
  end
end
