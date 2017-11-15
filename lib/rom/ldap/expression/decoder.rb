using ::BER

module ROM
  module LDAP
    class Expression
      #
      # @api private
      class Decoder

        def call(ber)
          binding.pry
          identifier = LOOKUP.invert[ber.ber_identifier]

          case identifier
          when LOOKUP[:con_and]
            ber.map { |b| call(b) }.inject { |memo, obj| [:con_and, memo, obj] }

          when LOOKUP[:con_or]
            ber.map { |b| call(b) }.inject { |memo, obj| [:con_or, memo, obj] }

          when LOOKUP[:con_not]
            # [:~, ber.first]
            [:con_not, ber.first, nil]

          when LOOKUP[:equality_match]
            [:op_equal, ber.first, ber.last] if ber.last == WILDCARD

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

            [:op_equal, ber.first.to_s, str]

          when LOOKUP[:op_gt_eq]
            [:op_gt_eq, ber.first.to_s, ber.last.to_s]

          when LOOKUP[:op_lt_eq]
            [:op_lt_eq, ber.first.to_s, ber.last.to_s]

          when LOOKUP[:is_present]
            then [:present, ber.to_s]

          when LOOKUP[:op_ext]

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

            [:op_ext, attribute, value]
          else
            raise Error, "Invalid BER tag-value (#{ber.ber_identifier}) in search filter."
          end
        end
      end
    end
  end
end
