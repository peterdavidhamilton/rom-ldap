# require 'stringio'

module BER
  refine ::String do

    def read_ber(syntax = nil)
      BER.function.read_ber(self, syntax)
    end

    def read_ber_length
      BER.function.read_ber_length(self)
    end

    def parse_ber_object(syntax, id, data)
      BER.function.parse_ber_object(self, syntax, id, data)
    end


    # def read_ber(syntax = nil)
    #   rule_logic.read_ber(syntax)
    # end

    # def read_ber_length
    #   rule_logic.read_ber_length
    # end

    # def parse_ber_object(syntax, id, data)
    #   rule_logic.parse_ber_object(syntax, id, data)
    # end

    # def rule_logic
    #   @rule_logic ||= RuleLogic.new(self)
    # end




    def to_ber(code = 0x04)
      raw_string = raw_utf8_encoded
      [code].pack('C') + raw_string.length.to_ber_length_encoding + raw_string
    end


    def to_ber_bin(code = 0x04)
      [code].pack('C') + length.to_ber_length_encoding + self
    end


    def raw_utf8_encoded
      if self.respond_to?(:encode)
        begin
          self.encode('UTF-8').force_encoding('ASCII-8BIT')
        rescue Encoding::UndefinedConversionError
          self
        rescue Encoding::ConverterNotFoundError
          self
        rescue Encoding::InvalidByteSequenceError
          self
        end
      else
        self
      end
    end
    private :raw_utf8_encoded


    def to_ber_application_string(code)
      to_ber(0x40 + code)
    end


    def to_ber_contextspecific(code)
      to_ber(0x80 + code)
    end

    def read_ber(syntax = nil)
      ::StringIO.new(self).read_ber(syntax)
    end

    def read_ber!(syntax = nil)
      io = ::StringIO.new(self)

      result = io.read_ber(syntax)
      self.slice!(0...io.pos)

      return result
    end

    def reject_empty_ber_arrays
      self.gsub(/0\000/n, '')
    end
  end
end
