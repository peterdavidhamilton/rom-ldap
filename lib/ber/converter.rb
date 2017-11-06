using ::BER

require 'dry/initializer'

module BER
  class Converter
    EXTENSIBLE_REGEX = /^([-;\w]*)(:dn)?(:(\w+|[.\w]+))?$/
    UNESCAPE_REGEX   = /\\([a-fA-F\d]{2})/

    extend Dry::Initializer

    param :op
    param :left
    param :right

    def call
      case op

      when :eq
        if right == WILDCARD
          left.to_s.to_ber_contextspecific(7)

        elsif right =~ /[*]/ # substring

          ary = right.split(/[*]+/, -1)

          if ary.first.empty?
            first = nil
            ary.shift
          else
            first = unescape(ary.shift).to_ber_contextspecific(0)
          end

          if ary.last.empty?
            last = nil
            ary.pop
          else
            last = unescape(ary.pop).to_ber_contextspecific(2)
          end

          seq = ary.map { |e| unescape(e).to_ber_contextspecific(1) }
          seq.unshift first if first
          seq.push last if last

          [left.to_s.to_ber, seq.to_ber].to_ber_contextspecific(4)
        else # equality
          [left.to_s.to_ber, unescape(right).to_ber].to_ber_contextspecific(3)
        end

      # make sure data is not forced to UTF-8
      when :bineq
        [left.to_s.to_ber, unescape(right).to_ber_bin].to_ber_contextspecific(3)

      when :ex
        seq = []

        raise(Error, "Bad attribute #{left}") unless left =~ EXTENSIBLE_REGEX

        type = Regexp.last_match(1)
        dn   = Regexp.last_match(2)
        rule = Regexp.last_match(4)

        seq << rule.to_ber_contextspecific(1) unless rule.to_s.empty? # matchingRule
        seq << type.to_ber_contextspecific(2) unless type.to_s.empty? # type
        seq << unescape(right).to_ber_contextspecific(3)              # matchingValue
        seq << '1'.to_ber_contextspecific(4) unless dn.to_s.empty?    # dnAttributes

        seq.to_ber_contextspecific(9)

      when :ge
        [left.to_s.to_ber, unescape(right).to_ber].to_ber_contextspecific(5)

      when :le
        [left.to_s.to_ber, unescape(right).to_ber].to_ber_contextspecific(6)

      when :ne
        [self.class.eq(left, right).to_ber].to_ber_contextspecific(2)

      when :and
        ary = [left.coalesce(:and), right.coalesce(:and)].flatten
        ary.map(&:to_ber).to_ber_contextspecific(0)

      when :or
        ary = [left.coalesce(:or), right.coalesce(:or)].flatten
        ary.map(&:to_ber).to_ber_contextspecific(1)

      when :not
        [left.to_ber].to_ber_contextspecific(2)
      end
    end

    private

    # Converts escaped characters to unescaped characters
    #
    # @example
    #   => "\\28"
    #
    # @return [String]
    #
    # @api private
    def unescape(right)
      right.to_s.gsub(UNESCAPE_REGEX) { [Regexp.last_match(1).hex].pack('U') }
    end
  end
end
