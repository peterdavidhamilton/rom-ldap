# @see http://tools.ietf.org/html/rfc4511#section-5.1
#
module BER

  refine TrueClass do
    # Converts +true+ to the BER wireline representation of +true+.
    def to_ber
      "\001\001\xFF".force_encoding('ASCII-8BIT')
    end

  end
end
