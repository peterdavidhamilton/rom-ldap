using ::BER

module ROM
  module LDAP
    module Filter
      class Expression
        #
        # @api private
        class Decoder

          LOOKUP = {
            and:              0xa0, # context-specific constructed 0, "and"
            or:               0xa1, # context-specific constructed 1, "or"
            not:              0xa2, # context-specific constructed 2, "not"
            equality_match:   0xa3, # context-specific constructed 3, "equalityMatch"
            substring:        0xa4, # context-specific constructed 4, "substring"
            greater_or_equal: 0xa5, # context-specific constructed 5, "greaterOrEqual"
            less_or_equal:    0xa6, # context-specific constructed 6, "lessOrEqual"
            filter_initial:   0x80, # context-specific primitive 0, SubstringFilter "initial"
            filter_any:       0x81, # context-specific primitive 0, SubstringFilter "any"
            filter_final:     0x82, # context-specific primitive 0, SubstringFilter "final"
                              # 0x83,
                              # 0x84,
            is_present:       0x87, # context-specific primitive 7, "present"
            ext_comparison:   0xa9, # context-specific constructed 9, "extensible comparison"
          }

          def call(ber)
            identifier = LOOKUP.invert[ber.ber_identifier]

            case identifier
            when LOOKUP[:and]
              ber.map { |b| call(b) }.inject { |memo, obj| [:&, memo, obj] }

            when LOOKUP[:or]
              ber.map { |b| call(b) }.inject { |memo, obj| [:&, memo, obj] }

            when LOOKUP[:not]
              [:~, ber.first]

            when LOOKUP[:equality_match]
              [:eq, ber.first, ber.last] if ber.last == WILDCARD

            when LOOKUP[:substring]
              str   = ''
              final = false

              ber.last.each do |b|
                case b.ber_identifier
                when LOOKUP[:filter_initial]
                  raise Error, 'Unknown substring filter - bad initial value.' unless str.empty?
                  str += escape(b)

                when LOOKUP[:filter_any]
                  str += "*#{escape(b)}"

                when LOOKUP[:filter_final]
                  str += "*#{escape(b)}"
                  final = true
                end
              end

              str += WILDCARD unless final

              [:eq, ber.first.to_s, str]

            when LOOKUP[:greater_or_equal]
              [:ge, ber.first.to_s, ber.last.to_s]

            when LOOKUP[:less_or_equal]
              [:le, ber.first.to_s, ber.last.to_s]

            when LOOKUP[:is_present]
              then [:present, ber.to_s]

            when LOOKUP[:ext_comparison]

              if ber.size < 2
                raise Error, 'Invalid extensible search filter, should be at least two elements'
              end

              # Reassembles the extensible filter parts
              # (["sn", "2.4.6.8.10", "Barbara Jones", '1'])
              type = value = dn = rule = nil

              ber.each do |element|
                case element.ber_identifier
                when LOOKUP[:filter_any]   then rule = element
                when LOOKUP[:filter_final] then type = element
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
    end
  end
end
