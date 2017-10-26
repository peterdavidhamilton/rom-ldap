require_relative 'ber_converter'
require_relative 'filter_parser'


require 'dry-types'

module ROM
  module LDAP
    class Dataset
      class Filter

# Basic Encoding Rules (BER)
# ber_identifier s

# const hex  dec
# ?   = 0x80 128 # context-specific primitive 0, SubstringFilter "initial"
# ?   = 0x81 129 # context-specific primitive 0, SubstringFilter "any"
# ?   = 0x82 130 # context-specific primitive 0, SubstringFilter "final"
# ?   = 0x83 131 # #ex: value=element
# ?   = 0x84 132 # #ex: dn='dn'
# ?   = 0x87 135 # context-specific primitive 7, "present"

# ?   = 0xa0 160 # context-specific constructed 0, "and"
# ?   = 0xa1 161 # context-specific constructed 1, "or"
# ?   = 0xa2 162 # context-specific constructed 2, "not"

# ?   = 0xa3 163 # context-specific constructed 3, "equalityMatch"
# ?   = 0xa4 164 # context-specific constructed 4, "substring"
# ?   = 0xa5 165 # context-specific constructed 5, "greaterOrEqual"
# ?   = 0xa6 166 # context-specific constructed 6, "lessOrEqual"
# ?   = 0xa9 169 # context-specific constructed 9, "extensible comparison"


        WILDCARD = '*'.freeze


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
        #   @op = op
        #   @left = left
        #   @right = right
        # end






# Class Methods - public API --------------------------------
        class << self

          # allow access to instance methods
          # private :new

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

          # def present?(attribute)
          #   eq(attribute, WILDCARD)
          # end

          # alias_method :present, :present?
          # alias_method :pres, :present?

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



          # another recursive method - should be dedicated class
          # Basic Encoding Rules (BER)
          #
          def parse_ber(ber)
            case ber.ber_identifier

            # context-specific constructed 0, "and"
            when 0xa0
              ber.map { |b| parse_ber(b) }.inject { |memo, obj| memo & obj }

            # context-specific constructed 1, "or"
            when 0xa1
              ber.map { |b| parse_ber(b) }.inject { |memo, obj| memo | obj }

            # context-specific constructed 2, "not"
            when 0xa2
              ~parse_ber(ber.first)

            # context-specific constructed 3, "equalityMatch"
            when 0xa3
              if ber.last == WILDCARD
                # nil implicit here?
              else
                eq(ber.first, ber.last)
              end

            # context-specific constructed 4, "substring"
            when 0xa4
              str = ""
              final = false

              ber.last.each do |b|
                case b.ber_identifier

                # context-specific primitive 0, SubstringFilter "initial"
                when 0x80

                  # raise Net::LDAP::SubstringFilterError, "Unrecognized substring filter; bad initial value." if str.length > 0
                  abort "Unrecognized substring filter; bad initial value." if str.length > 0

                  str += escape(b)

                # context-specific primitive 0, SubstringFilter "any"
                when 0x81
                  str += "*#{escape(b)}"

                # context-specific primitive 0, SubstringFilter "final"
                when 0x82
                  str += "*#{escape(b)}"
                  final = true
                end
              end

              str += WILDCARD unless final
              eq(ber.first.to_s, str)


            # context-specific constructed 5, "greaterOrEqual"
            when 0xa5
              ge(ber.first.to_s, ber.last.to_s)

            # context-specific constructed 6, "lessOrEqual"
            when 0xa6
              le(ber.first.to_s, ber.last.to_s)

            # context-specific primitive 7, "present"
            when 0x87
              # call to_s to get rid of the BER-identifiedness of the incoming string.
              present?(ber.to_s)

            # context-specific constructed 9, "extensible comparison"
            when 0xa9

                    # raise Net::LDAP::SearchFilterError, "Invalid extensible search filter, should be at least two elements" if ber.size < 2
                    if ber.size < 2
                      abort "Invalid extensible search filter, should be at least two elements"
                    end

                    # Reassembles the extensible filter parts
                    # (["sn", "2.4.6.8.10", "Barbara Jones", '1'])
                    type = value = dn = rule = nil

                    ber.each do |element|
                      case element.ber_identifier
                        # when 0x81 then rule=element
                        # when 0x82 then type=element
                        # when 0x83 then value=element
                        # when 0x84 then dn='dn'
                        when 0x81
                          rule = element
                        when 0x82
                          type = element
                        when 0x83
                          value = element
                        when 0x84
                          dn = 'dn'
                      end
                    end

                    attribute = ''
                    attribute << type if type
                    attribute << ":#{dn}" if dn
                    attribute << ":#{rule}" if rule

                    ex(attribute, value)
            else

              # raise Net::LDAP::BERInvalidError, "Invalid BER tag-value (#{ber.ber_identifier}) in search filter."
              abort "Invalid BER tag-value (#{ber.ber_identifier}) in search filter."

            end
          end





          # extracted class - end point for the DSL - converted to a callable class
          #
          # Converts an LDAP filter-string (in the prefix syntax specified in RFC-2254)
          # to a Net::LDAP::Filter.
          #
          def construct(ldap_filter_string)
            # ::FilterParser.parse(ldap_filter_string)
            # binding.pry
            # ::FilterParser.new(ldap_filter_string, self).filter
            ::FilterParser.new(self).call(ldap_filter_string)
          end

          # alias_method :from_rfc2254, :construct
          # alias_method :from_rfc4515, :construct







          # Convert an RFC-1777 LDAP/BER "Filter" object to a Net::LDAP::Filter
          # object.
          #--
          # TODO, we're hardcoding the RFC-1777 BER-encodings of the various
          # filter types. Could pull them out into a constant.
          #++
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

        ##
        # Negates a filter.
        #
        #   # Selects only entries that do not have an <tt>objectclass</tt>
        #   # attribute.
        #   x = ~Net::LDAP::Filter.present("objectclass")
        def ~@
          self.class.negate(self)
        end

        ##
        # Equality operator for filters, useful primarily for constructing unit tests.
        # 20100320 AZ: We need to come up with a better way of doing this. This
        # is just nasty.
        def ==(filter)
          str = "[@op,@left,@right]"
          self.instance_eval(str) == filter.instance_eval(str)
        end



        # should be the call method?
        # a recursive method
        #
        def to_raw_rfc2254
          case @op
          when :ne
            "!(#{@left}=#{@right})"
          when :eq, :bineq
            "#{@left}=#{@right}"
          when :ex    # could be useful with Active Directory extension
            "#{@left}:=#{@right}"
          when :ge
            "#{@left}>=#{@right}"
          when :le
            "#{@left}<=#{@right}"

            # from here it is recursive

          when :and
            "&(#{@left.to_raw_rfc2254})(#{@right.to_raw_rfc2254})"
          when :or
            "|(#{@left.to_raw_rfc2254})(#{@right.to_raw_rfc2254})"
          when :not
            "!(#{@left.to_raw_rfc2254})"
          end
        end



        # wrap with parentheses
        ##
        # Converts the Filter object to an RFC 2254-compatible text format.
        def to_rfc2254
          "(#{to_raw_rfc2254})"
        end

        alias_method :to_s, :to_rfc2254

        # def to_s
        #   to_rfc2254
        # end


        # extracted to a separate file.
        #
        def to_ber
          ::BerConverter.new(@op, @left, @right).call
          # ::BerConverter.new(op, left, right).call
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
        #   case @op
        #   when :eq
        #     if @right == WILDCARD
        #       yield :present, @left
        #     elsif @right.index '*'
        #       yield :substrings, @left, @right
        #     else
        #       yield :equalityMatch, @left, @right
        #     end
        #   when :ge
        #     yield :greaterOrEqual, @left, @right
        #   when :le
        #     yield :lessOrEqual, @left, @right
        #   when :or, :and
        #     yield @op, (@left.execute(&block)), (@right.execute(&block))
        #   when :not
        #     yield @op, (@left.execute(&block))
        #   end || []
        # end





        ##
        # This is a private helper method for dealing with chains of ANDs and ORs
        # that are longer than two. If BOTH of our branches are of the specified
        # type of joining operator, then return both of them as an array (calling
        # coalesce recursively). If they're not, then return an array consisting
        # only of self.
        def coalesce(operator) #:nodoc:
          if @op == operator
            [@left.coalesce(operator), @right.coalesce(operator)]
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
          case @op
          when :eq
            if @right == WILDCARD
              l = entry[@left] and l.length > 0
            else
              l = entry[@left] and l = Array(l) and l.index(@right)
            end
          else
            # raise Net::LDAP::FilterTypeUnknownError, "Unknown filter type in match: #{@op}"
            abort "Unknown filter type in match: #{@op}"
          end
        end




        # ##
        # # Converts escaped characters (e.g., "\\28") to unescaped characters
        # def unescape(right)
        #   right.to_s.gsub(/\\([a-fA-F\d]{2})/) { [$1.hex].pack("U") }
        # end

        # private :unescape



      end # class Net::LDAP::Filter
    end # Dataset
  end # LDAP
end # ROM
