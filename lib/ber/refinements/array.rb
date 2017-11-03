module BER
  refine ::Array do

    def to_ber(id = 0)
      to_ber_seq_internal(0x30 + id)
    end

    alias_method :to_ber_sequence, :to_ber

    def to_ber_set(id = 0)
      to_ber_seq_internal(0x31 + id)
    end

    def to_ber_appsequence(id = 0)
      to_ber_seq_internal(0x60 + id)
    end

    def to_ber_contextspecific(id = 0)
      to_ber_seq_internal(0xa0 + id)
    end

    def to_ber_seq_internal(code)
      s = self.join
      [code].pack('C') + s.length.to_ber_length_encoding + s
    end

    private :to_ber_seq_internal

    def to_ber_oid
      ary = self.dup
      first = ary.shift
      raise Net::BER::BerError, "Invalid OID" unless [0, 1, 2].include?(first)
      first = first * 40 + ary.shift
      ary.unshift first
      oid = ary.pack("w*")
      [6, oid.length].pack("CC") + oid
    end

    def to_ber_control
      ary = self[0].kind_of?(Array) ? self : [self]
      ary = ary.collect do |control_sequence|
        control_sequence.collect(&:to_ber).to_ber_sequence.reject_empty_ber_arrays
      end
      ary.to_ber_sequence.reject_empty_ber_arrays
    end
  end
end
