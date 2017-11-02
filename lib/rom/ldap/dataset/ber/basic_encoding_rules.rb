module BasicEncodingRules

  BuiltinSyntax = Net::BER.compile_syntax(ROM::LDAP.config[:builtin_syntax]).freeze

  # == is expensive so sort this so the common cases are at the top.

  def parse_ber_object(syntax, id, data)

    object_type = (syntax && syntax[id]) || BuiltinSyntax[id]

    if object_type == :string
      s = Net::BER::BerIdentifiedString.new(data || "")
      s.ber_identifier = id
      s
    elsif object_type == :integer
      neg = !(data.unpack("C").first & 0x80).zero?
      int = 0

      data.each_byte do |b|
        int = (int << 8) + (neg ? 255 - b : b)
      end

      if neg
        (int + 1) * -1
      else
        int
      end

    elsif object_type == :oid
      oid = data.unpack("w*")
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
      # Net::BER::BerIdentifiedOid.new(oid)
      oid
    elsif object_type == :array
      seq = Net::BER::BerIdentifiedArray.new
      seq.ber_identifier = id
      sio = StringIO.new(data || "")
      # Interpret the subobject, but note how the loop is built:
      # nil ends the loop, but false (a valid BER value) does not!
      while (e = sio.read_ber(syntax)) != nil
        seq << e
      end
      seq
    elsif object_type == :boolean
      data != "\000"
    elsif object_type == :null
      n = Net::BER::BerIdentifiedNull.new
      n.ber_identifier = id
      n
    else
      raise Net::BER::BerError, "Unsupported object type: id=#{id}"
    end
  end

  def read_ber_length
    n = getbyte

    if n <= 0x7f
      n
    elsif n == 0x80
      -1
    elsif n == 0xff
      raise Net::BER::BerError, "Invalid BER length 0xFF detected."
    else
      v = 0
      read(n & 0x7f).each_byte do |b|
        v = (v << 8) + b
      end

      v
    end
  end


  def read_ber(syntax = nil)
    id = getbyte or return nil  # don't trash this value, we'll use it later

    content_length = read_ber_length

    yield id, content_length if block_given?

    if -1 == content_length
      raise Net::BER::BerError,
            "Indeterminite BER content length not implemented."
    end
    data = read(content_length)

    parse_ber_object(syntax, id, data)
  end


end
