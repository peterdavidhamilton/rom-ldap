# require_relative 'ber/refinements'
require 'dry-types'

module ROM
  module LDAP
    class Dataset

      EQUAL     = '='.freeze
      NOT_EQUAL = '!='.freeze
      LESS_THAN = '<='.freeze
      MORE_THAN = '>='.freeze
      EXT_COMP  = ':='.freeze
      WILDCARD  = '*'.freeze

      OPERATOR_REGEX = Regexp.union(EQUAL, NOT_EQUAL, LESS_THAN, MORE_THAN, EXT_COMP).freeze

      TOKEN_REGEX    =  %r"[-\w:.]*[\w]".freeze

      # contains unescape regex
      VALUE_REGEX    =  /(?:[-\[\]{}\w*.+\/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]|[^\x00-\x7F]|\\[a-fA-F\d]{2})+/u.freeze


      EXTENSIBLE_REGEX = /^([-;\w]*)(:dn)?(:(\w+|[.\w]+))?$/.freeze


      WS_REGEX       =  /\s*/.freeze

      UNESCAPE_REGEX = /\\([a-fA-F\d]{2})/.freeze

      class FilterDSL

        # extend Initializer
        extend Dry::Initializer

        param :op,    reader: :private, type: Dry::Types['strict.symbol']
        param :left,  reader: :private
        param :right, reader: :private, optional: true


        # FilterMethods = [:ne, :eq, :ge, :le, :and, :or, :not, :ex, :bineq].freeze
        # param :op,    reader: :private, type: ->(v) { FilterMethods.include?(v) }


        # def initialize(op, left, right)
        #   unless FilterTypes.include?(op)
        #     raise Net::LDAP::OperatorError, "Invalid or unsupported operator #{op.inspect} in LDAP Filter."
        #   end
        #   op = op
        #   left = left
        #   right = right
        # end






# Class Methods - public API --------------------------------
        class << self

          # allow access to instance methods
          private :new

          def eq(attribute, value)
            new(:eq, attribute, value)
          end

              def equals(attribute, value)
                new(:eq, attribute, escape(value))
              end

              def begins(attribute, value)
                new(:eq, attribute, escape(value) + WILDCARD)
              end

              def ends(attribute, value)
                new(:eq, attribute, WILDCARD + escape(value))
              end

              def contains(attribute, value)
                new(:eq, attribute, WILDCARD + escape(value) + WILDCARD)
              end


          def bineq(attribute, value)
            new(:bineq, attribute, value)
          end

          def ex(attribute, value)
            new(:ex, attribute, value)
          end

          def ne(attribute, value)
            new(:ne, attribute, value)
          end

          def ge(attribute, value)
            new(:ge, attribute, value)
          end

          def le(attribute, value)
            new(:le, attribute, value)
          end

          def join(left, right)
            new(:and, left, right)
          end

          def intersect(left, right)
            new(:or, left, right)
          end

          def negate(filter)
            new(:not, filter, nil)
          end

          def present?(attribute)
            eq(attribute, WILDCARD)
          end

          alias_method :present, :present?
          alias_method :pres, :present?

          def present(attribute)
            eq(attribute, WILDCARD)
          end



          ESCAPES = {
            "\0" => '00', # NUL      = %x00 ; null character
            '*'  => '2A', # ASTERISK = %x2A ; asterisk (WILDCARD)
            '('  => '28', # LPARENS  = %x28 ; left parenthesis ("(")
            ')'  => '29', # RPARENS  = %x29 ; right parenthesis (")")
            '\\' => '5C', # ESC      = %x5C ; esc (or backslash) ("\")
          }.freeze


          # Compiled character class regexp using the keys from the above hash.
          ESCAPE_RE = Regexp.new("[" + ESCAPES.keys.map { |e| Regexp.escape(e) }.join + "]")


          # Escape a string for use in an LDAP filter
          #
          def escape(string)
            string.gsub(ESCAPE_RE) { |char| "\\" + ESCAPES[char] }
          end



          def parse_ber(ber)
            BerParser.new(ber).call
          end



          def construct(ldap_filter_string)
            FilterParser.new(self).call(ldap_filter_string)
          end



          def parse_ldap_filter(obj)
            case obj.ber_identifier

            # present. context-specific primitive 7.
            when 0x87
              eq(obj.to_s, WILDCARD)

            # equalityMatch. context-specific constructed 3.
            when 0xa3
              eq(obj[0], obj[1])

            else

              # raise Net::LDAP::SearchFilterTypeUnknownError, "Unknown LDAP search-filter type: #{obj.ber_identifier}"
              abort "Unknown LDAP search-filter type: #{obj.ber_identifier}"

            end
          end


        end # self end of class methods





# ---------- Instance Methods -------------------------

        def &(filter)
          self.class.join(self, filter)
        end


        def |(filter)
          self.class.intersect(self, filter)
        end



        def ~@
          self.class.negate(self)
        end




        # should be the call method?
        # a recursive method
        #
        def to_raw_rfc2254
          case op
          when :ne
            "!(#{left}=#{right})"
          when :eq, :bineq
            "#{left}=#{right}"
          when :ex    # could be useful with Active Directory extension
            "#{left}:=#{right}"
          when :ge
            "#{left}>=#{right}"
          when :le
            "#{left}<=#{right}"

            # from here it is recursive

          when :and
            "&(#{left.to_raw_rfc2254})(#{right.to_raw_rfc2254})"
          when :or
            "|(#{left.to_raw_rfc2254})(#{right.to_raw_rfc2254})"
          when :not
            "!(#{left.to_raw_rfc2254})"
          end
        end




        def to_rfc2254
          "(#{to_raw_rfc2254})"
        end

        alias_method :to_s, :to_rfc2254



        def to_ber
          BerConverter.new(op, left, right).call
        end







        ##
        # Perform filter operations against a user-supplied block. This is useful
        # when implementing an LDAP directory server. The caller's block will be
        # called with two arguments: first, a symbol denoting the "operation" of
        # the filter; and second, an array consisting of arguments to the
        # operation. The user-supplied block (which is MANDATORY) should perform
        # some desired application-defined processing, and may return a
        # locally-meaningful object that will appear as a parameter in the :and,
        # :or and :not operations detailed below.
        #
        # A typical object to return from the user-supplied block is an array of
        # Net::LDAP::Filter objects.
        #
        # These are the possible values that may be passed to the user-supplied
        # block:
        #   * :equalityMatch (the arguments will be an attribute name and a value
        #     to be matched);
        #   * :substrings (two arguments: an attribute name and a value containing
        #     one or more WILDCARD characters);
        #   * :present (one argument: an attribute name);
        #   * :greaterOrEqual (two arguments: an attribute name and a value to be
        #     compared against);
        #   * :lessOrEqual (two arguments: an attribute name and a value to be
        #     compared against);
        #   * :and (two or more arguments, each of which is an object returned
        #     from a recursive call to #execute, with the same block;
        #   * :or (two or more arguments, each of which is an object returned from
        #     a recursive call to #execute, with the same block; and
        #   * :not (one argument, which is an object returned from a recursive
        #     call to #execute with the the same block.

        # def execute(&block)
        #   case op
        #   when :eq
        #     if right == WILDCARD
        #       yield :present, left
        #     elsif right.index '*'
        #       yield :substrings, left, right
        #     else
        #       yield :equalityMatch, left, right
        #     end
        #   when :ge
        #     yield :greaterOrEqual, left, right
        #   when :le
        #     yield :lessOrEqual, left, right
        #   when :or, :and
        #     yield op, (left.execute(&block)), (right.execute(&block))
        #   when :not
        #     yield op, (left.execute(&block))
        #   end || []
        # end





        ##
        # This is a private helper method for dealing with chains of ANDs and ORs
        # that are longer than two. If BOTH of our branches are of the specified
        # type of joining operator, then return both of them as an array (calling
        # coalesce recursively). If they're not, then return an array consisting
        # only of self.
        def coalesce(operator) #:nodoc:
          if op == operator
            [left.coalesce(operator), right.coalesce(operator)]
          else
            [self]
          end
        end




        ##
        #--
        # We got a hash of attribute values.
        # Do we match the attributes?
        # Return T/F, and call match recursively as necessary.
        #++
        #
        # flow control ------ ! use guard clause?
        def match(entry)
          case op
          when :eq
            if right == WILDCARD
              l = entry[left] and l.length > 0
            else
              l = entry[left] and l = Array(l) and l.index(right)
            end
          else
            # raise Net::LDAP::FilterTypeUnknownError, "Unknown filter type in match: #{op}"
            abort "Unknown filter type in match: #{op}"
          end
        end




        # ##
        # # Converts escaped characters (e.g., "\\28") to unescaped characters
        # def unescape(right)
        #   right.to_s.gsub(/\\([a-fA-F\d]{2})/) { [$1.hex].pack("U") }
        # end

        # private :unescape

      end
    end
  end
end
