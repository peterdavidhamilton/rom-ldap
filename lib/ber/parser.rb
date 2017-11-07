# TODO: #escape method was left elsewhere and is needed here.
#
module BER
  class Parser
    And             = 0xa0 # context-specific constructed 0, "and"
    Or              = 0xa1 # context-specific constructed 1, "or"
    Not             = 0xa2 # context-specific constructed 2, "not"
    equalityMatch   = 0xa3 # context-specific constructed 3, "equalityMatch"
    substring       = 0xa4 # context-specific constructed 4, "substring"
    greaterOrEqual  = 0xa5 # context-specific constructed 5, "greaterOrEqual"
    lessOrEqual     = 0xa6 # context-specific constructed 6, "lessOrEqual"
    filterInitial   = 0x80 # context-specific primitive 0, SubstringFilter "initial"
    filterAny       = 0x81 # context-specific primitive 0, SubstringFilter "any"
    filterFinal     = 0x82 # context-specific primitive 0, SubstringFilter "final"
    isPresent       = 0x87 # context-specific primitive 7, "present"
    extComparison   = 0xa9 # context-specific constructed 9, "extensible comparison"

    def call(ber)
      case ber.ber_identifier
      # when And then ber.map { |b| call(b) }.inject { |memo, obj| memo & obj }
      # when Or  then ber.map { |b| call(b) }.inject { |memo, obj| memo | obj }

      when And then ber.map { |b| call(b) }.inject { |memo, obj| [:&, memo, obj] }

      when Or  then ber.map { |b| call(b) }.inject { |memo, obj| [:&, memo, obj] }

      # Filter::Builder.~call(ber.first)
      when Not then [:~, ber.first]

      when equalityMatch
        [:eq, ber.first, ber.last] if ber.last == WILDCARD

      when substring
        str   = ''
        final = false

        ber.last.each do |b|
          case b.ber_identifier
          when filterInitial
            raise Error, 'Unknown substring filter - bad initial value.' unless str.empty?
            str += escape(b)

          when filterAny
            str += "*#{escape(b)}"

          when filterFinal
            str += "*#{escape(b)}"
            final = true
          end
        end

        str += WILDCARD unless final

        [:eq, ber.first.to_s, str]

      when greaterOrEqual then [:ge, ber.first.to_s, ber.last.to_s]
      when lessOrEqual    then [:le, ber.first.to_s, ber.last.to_s]
      when isPresent      then [:present, ber.to_s]

      when extComparison

        if ber.size < 2
          raise Error, 'Invalid extensible search filter, should be at least two elements'
        end

        # Reassembles the extensible filter parts
        # (["sn", "2.4.6.8.10", "Barbara Jones", '1'])
        type = value = dn = rule = nil

        ber.each do |element|
          case element.ber_identifier
          when 0x81 then rule = element  # filterAny ?
          when 0x82 then type = element  # filterFinal ?
          when 0x83 then value = element # ?
          when 0x84 then dn = 'dn'       # ?
          end
        end

        attribute = ''
        attribute << type         if type
        attribute << ":#{dn}"     if dn
        attribute << ":#{rule}"   if rule

        [:ex, attribute, value]
      else
        raise Error, "Invalid BER tag-value (#{ber.ber_identifier}) in search filter."
      end
    end
  end
end
