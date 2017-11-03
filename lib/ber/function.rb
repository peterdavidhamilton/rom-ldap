require 'ber/identified'

module BER
  class Function

    def parse_ber_object(object, syntax, id, data)
      object_type = (syntax && syntax[id]) || BUILTIN_SYNTAX[id]

      case object_type
      when :string
        s = BerIdentifiedString.new(data || EMPTY_STRING)
        s.ber_identifier = id
        s

      when :integer
        neg = !(data.unpack('C').first & 0x80).zero?
        int = 0

        data.each_byte do |b|
          int = (int << 8) + (neg ? 255 - b : b)
        end

        if neg
          (int + 1) * -1
        else
          int
        end

      when :oid
        oid = data.unpack('w*')
        f = oid.shift
        g = if f < 40
              [0, f]
            elsif f < 80
              [1, f - 40]
            else
              [2, f - 80]
            end
        oid.unshift g.last
        oid.unshift g.first
        BerIdentifiedOid.new(oid)
        # oid

      when :array
        seq = BerIdentifiedArray.new
        seq.ber_identifier = id
        sio = StringIO.new(data || EMPTY_STRING)

        while !(e = read_ber(sio, syntax)).nil?
          seq << e
        end
        seq

      when :boolean
        data != "\000"

      when :null
        n = BerIdentifiedNull.new
        n.ber_identifier = id
        n

      else
        raise Error, "Unsupported object type: id=#{id}"
      end
    end

    def read_ber_length(object)
      n = object.getbyte

      if n <= 0x7f
        n
      elsif n == 0x80
        -1
      elsif n == 0xff
        raise Error, 'Invalid BER length 0xFF detected.'
      else
        v = 0
        object.read(n & 0x7f).each_byte do |b|
          v = (v << 8) + b
        end

        v
      end
    end

    def read_ber(object, syntax = nil)

      if id = object.getbyte
        content_length = read_ber_length(object)

        yield id, content_length if block_given?

        if content_length == -1
          raise Error, 'Indeterminite BER content length not implemented.'
        end

        data = object.read(content_length)

        parse_ber_object(object, syntax, id, data)
      end
    end
  end
end
