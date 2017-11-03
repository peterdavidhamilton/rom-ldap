module BER
  class BerIdentifiedString < String
    attr_accessor :ber_identifier

    def initialize(args)
      super

      return unless encoding == Encoding::BINARY
      current_encoding = encoding
      force_encoding('UTF-8')
      force_encoding(current_encoding) unless valid_encoding?
    end
  end
end
