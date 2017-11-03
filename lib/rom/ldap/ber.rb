module ROM
  module LDAP

    # Basic Encoding Rules
    module BER
      # # name , hex , decimal , type , desc
      # [ '?', 0xa0, 160, '' ] # context-specific constructed 0, "and"
      # [ '?', 0xa1, 161, '' ] # context-specific constructed 1, "or"
      # [ '?', 0xa2, 162, '' ] # context-specific constructed 2, "not"
      # [ '?', 0xa3, 163, '' ] # context-specific constructed 3, "equalityMatch"
      # [ '?', 0xa4, 164, '' ] # context-specific constructed 4, "substring"
      # [ '?', 0xa5, 165, '' ] # context-specific constructed 5, "greaterOrEqual"
      # [ '?', 0xa6, 166, '' ] # context-specific constructed 6, "lessOrEqual"
      # [ '?', 0xa9, 169, '' ] # context-specific constructed 9, "extensible comparison"

      # [ '?', 0x80, 128, 'SubstringFilter' ] # context-specific primitive 0, SubstringFilter "initial"
      # [ '?', 0x81, 129, 'SubstringFilter' ] # context-specific primitive 0, SubstringFilter "any"
      # [ '?', 0x82, 130, 'SubstringFilter' ] # context-specific primitive 0, SubstringFilter "final"
      # [ '?', 0x83, 131, '' ] # #ex: value=element
      # [ '?', 0x84, 132, '' ] # #ex: dn='dn'
      # [ '?', 0x87, 135, '' ] # context-specific primitive 7, "present"

      ##
      # Used for BER-encoding the length and content bytes of a Fixnum integer
      # values.
      MAX_FIXNUM_SIZE = 0.size

      TAG_CLASS = {
        universal: 0b00000000, # 0
        application: 0b01000000, # 64
        context_specific: 0b10000000, # 128
        private: 0b11000000, # 192
      }.freeze

      ENCODING_TYPE = {
        primitive: 0b00000000, # 0
        constructed: 0b00100000, # 32
      }.freeze

      def self.compile_syntax(syntax)
        out = [nil] * 256
        syntax.each do |tag_class_id, encodings|
          tag_class = TAG_CLASS[tag_class_id]
          encodings.each do |encoding_id, classes|
            encoding = ENCODING_TYPE[encoding_id]
            object_class = tag_class + encoding
            classes.each do |number, object_type|
              out[object_class + number] = object_type
            end
          end
        end
        out
      end

      class BerError < RuntimeError; end

      class BerIdentifiedArray < Array
        attr_accessor :ber_identifier

        def initialize(*args)
          super
        end
      end

      class BerIdentifiedOid
        attr_accessor :ber_identifier

        def initialize(oid)
          oid = oid.split(/\./).map(&:to_i) if oid.is_a?(String)
          @value = oid
        end

        def to_ber
          to_ber_oid
        end

        def to_ber_oid
          @value.to_ber_oid
        end

        def to_s
          @value.join('.')
        end

        def to_arr
          @value.dup
        end
      end

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

      class BerIdentifiedNull
        attr_accessor :ber_identifier

        def to_ber
          "\005\000"
        end
      end

      Null = BerIdentifiedNull.new
    end
  end
end
