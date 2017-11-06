module BER
  refine ::StringIO do
    def read_ber(syntax = nil)
      ::BER.function.read_ber(self, syntax)
    end

    # alias read read_ber # overwrite default Socket method for compatibility with Connection
    # # alias read_nonblock read_ber # overwrite default Socket method for compatibility with Connection

    # def read_nonblock(*args)
    #   binding.pry
    #   read(*args)
    # end

    def read_ber_length
      ::BER.function.read_ber_length(self)
    end

    def parse_ber_object(syntax, id, data)
      ::BER.function.parse_ber_object(self, syntax, id, data)
    end
  end
end
