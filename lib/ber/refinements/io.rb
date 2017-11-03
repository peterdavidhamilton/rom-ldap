module BER
  refine ::IO do
    def read_ber(syntax = nil)
      ::BER.function.read_ber(self, syntax)
    end

    def read_ber_length
      ::BER.function.read_ber_length(self)
    end

    def parse_ber_object(syntax, id, data)
      ::BER.function.parse_ber_object(self, syntax, id, data)
    end
  end
end
