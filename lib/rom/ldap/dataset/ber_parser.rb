module ROM
  module LDAP
    class Dataset
      # Basic Encoding Rules (BER)
      class BerParser

# name , hex , decimal , type , desc
[ '?', 0xa0, 160, '' ] # context-specific constructed 0, "and"
[ '?', 0xa1, 161, '' ] # context-specific constructed 1, "or"
[ '?', 0xa2, 162, '' ] # context-specific constructed 2, "not"
[ '?', 0xa3, 163, '' ] # context-specific constructed 3, "equalityMatch"
[ '?', 0xa4, 164, '' ] # context-specific constructed 4, "substring"
[ '?', 0xa5, 165, '' ] # context-specific constructed 5, "greaterOrEqual"
[ '?', 0xa6, 166, '' ] # context-specific constructed 6, "lessOrEqual"
[ '?', 0xa9, 169, '' ] # context-specific constructed 9, "extensible comparison"

[ '?', 0x80, 128, 'SubstringFilter' ] # context-specific primitive 0, SubstringFilter "initial"
[ '?', 0x81, 129, 'SubstringFilter' ] # context-specific primitive 0, SubstringFilter "any"
[ '?', 0x82, 130, 'SubstringFilter' ] # context-specific primitive 0, SubstringFilter "final"
[ '?', 0x83, 131, '' ] # #ex: value=element
[ '?', 0x84, 132, '' ] # #ex: dn='dn'
[ '?', 0x87, 135, '' ] # context-specific primitive 7, "present"

        def call(ber)
          case ber.ber_identifier

          # context-specific constructed 0, "and"
          when 0xa0
            ber.map { |b| call(b) }.inject { |memo, obj| memo & obj }

          # context-specific constructed 1, "or"
          when 0xa1
            ber.map { |b| call(b) }.inject { |memo, obj| memo | obj }

          # context-specific constructed 2, "not"
          when 0xa2
            ~call(ber.first)

          # context-specific constructed 3, "equalityMatch"
          when 0xa3
            if ber.last == WILDCARD
              # nil implicit here?
            else
              eq(ber.first, ber.last)
            end

          # context-specific constructed 4, "substring"
          when 0xa4
            str = ''
            final = false

            ber.last.each do |b|
              case b.ber_identifier

              # context-specific primitive 0, SubstringFilter "initial"
              when 0x80

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


                  if ber.size < 2
                    abort "Invalid extensible search filter, should be at least two elements"
                  end

                  # Reassembles the extensible filter parts
                  # (["sn", "2.4.6.8.10", "Barbara Jones", '1'])
                  type = value = dn = rule = nil

                  ber.each do |element|
                    case element.ber_identifier
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
            abort "Invalid BER tag-value (#{ber.ber_identifier}) in search filter."
          end
        end
      end

    end
  end
end
