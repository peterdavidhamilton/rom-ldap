# TODO: Uncouple BER::Parser from filter builder
# Instead parser should return array similar to:
#  [:eq, 'attribute', 'value']
#  [:present, 'attribute']
#
# Abstract the possible ber_identifier values
#
# #escape method was left elsewhere and is needed here.
#
require 'rom/ldap/dataset/filter/builder'

module ROM
  module LDAP

    module BER
      class Parser

        greaterOrEqual = "0xa5".freeze

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
            Filter::Builder.~call(ber.first)

          # context-specific constructed 3, "equalityMatch"
          when 0xa3
            if ber.last == WILDCARD
              # nil implicit here?
            else
              Filter::Builder.eq(ber.first, ber.last)
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
            # Filter::Builder.eq(ber.first.to_s, str)

            [:eq, ber.first.to_s, str]


          # context-specific constructed 5, "greaterOrEqual"
          when greaterOrEqual
            Filter::Builder.ge(ber.first.to_s, ber.last.to_s)

          # context-specific constructed 6, "lessOrEqual"
          when 0xa6
            Filter::Builder.le(ber.first.to_s, ber.last.to_s)

          # context-specific primitive 7, "present"
          when 0x87
            # call to_s to get rid of the BER-identifiedness of the incoming string.
            Filter::Builder.present?(ber.to_s)

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

                  # Filter::Builder.ex(attribute, value)
                  [:ex, attribute, value]
          else
            abort "Invalid BER tag-value (#{ber.ber_identifier}) in search filter."
          end
        end
      end

    end
  end
end
