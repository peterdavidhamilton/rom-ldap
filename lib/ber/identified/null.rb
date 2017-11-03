module BER
  class BerIdentifiedNull
    attr_accessor :ber_identifier

    def to_ber
      "\005\000"
    end
  end
end
