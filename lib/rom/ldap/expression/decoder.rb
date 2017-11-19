using ::BER

module ROM
  module LDAP
    class Expression
      #
      # @api private
      class Decoder

        def call(ber)
          binding.pry
          case identifier(ber)
          when request(:con_and) then and_or(:con_and)
          when request(:con_or)  then and_or(:con_or)
          when request(:con_not) then [:con_not, ber.first, nil]

          when request(:equality_match)
            # [:op_eql, ber.first, ber.last] if ber.last == WILDCARD
            [:op_eql, *ber] if ber.last == WILDCARD

          when request(:substring)  then substr(ber)
          when request(:op_gte)     then [:op_gte, *ber.map(&:to_s)]
          # when request(:op_gte)     then [:op_gte, ber.first.to_s, ber.last.to_s]
          when request(:op_lte)     then [:op_lte, ber.first.to_s, ber.last.to_s]
          when request(:is_present) then [:present, ber.to_s]
          when request(:op_ext)     then extensible(ber)
          else
            raise Error, "Invalid BER tag-value (#{ber.ber_identifier}) in search filter."
          end
        end

        private

        def and_or(op)
          ber.map { |b| call(b) }.inject { |memo, obj| [op, memo, obj] }
        end

        def extensible(ber)
          if ber.size < 2
            raise Error, 'Invalid extensible search filter, should be at least two elements'
          end

          # Reassembles the extensible filter parts
          # (["sn", "2.4.6.8.10", "Barbara Jones", '1'])
          type = value = dn = rule = nil

          ber.each do |element|
            case element.ber_identifier
            when request(:filter_any)
              rule = element
            when request(:filter_final)
              type = element
            when 0x83
              value = element # ?
            when 0x84
              dn = 'dn' # ?
            end
          end

          attribute = ''
          attribute << type       if type
          attribute << ":#{dn}"   if dn
          attribute << ":#{rule}" if rule

          [:op_ext, attribute, value]
        end

        def substr(ber)
          str   = ''
          final = false

          ber.last.each do |b|
            case b.ber_identifier
            when request(:substr_initial)
              raise Error, 'Unknown substring filter - bad initial value.' unless str.empty?
              str += escape(b)

            when request(:substr_any)
              str += "*#{escape(b)}"

            when request(:substr_final)
              str += "*#{escape(b)}"
              final = true
            end
          end

          str += WILDCARD unless final

          [:op_eql, ber.first.to_s, str]
        end

        def identifier(ber)
          BER.reverse_lookup(:request, ber.ber_identifier)
        end

        def request(key)
          BER.lookup(:request, key)
        end
      end
    end
  end
end
