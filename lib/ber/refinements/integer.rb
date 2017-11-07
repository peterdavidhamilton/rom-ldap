module BER
  refine ::Integer do
    def to_ber
      "\002#{to_ber_internal}"
    end

    def to_ber_enumerated
      "\012#{to_ber_internal}"
    end

    def to_ber_length_encoding
      if self <= 127
        [self].pack('C')
      else
        i = [self].pack('N').sub(/^[\0]+/, '')
        [0x80 + i.length].pack('C') + i
      end
    end

    def to_ber_application(tag)
      [0x40 + tag].pack('C') + to_ber_internal
    end

    private

    def to_ber_internal
      size  = 1
      size += 1 until ((self < 0 ? ~self : self) >> (size * 8)).zero?

      size += 1 if self > 0 && (self & (0x80 << (size - 1) * 8)) > 0

      size += 1 if self < 0 && (self & (0x80 << (size - 1) * 8)) == 0

      result = [size]

      while size > 0
        result << ((self >> ((size - 1) * 8)) & 0xff)
        size -= 1
      end

      result.pack('C*')
    end
  end
end
