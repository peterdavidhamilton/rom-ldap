require 'transproc'
require 'base64'
require 'rom/support/inflector'

module ROM
  module LDAP
    module Functions
      extend Transproc::Registry

      import Transproc::Coercions
      import Transproc::ArrayTransformations
      import Transproc::HashTransformations

      # import :to_string, from: Transproc::Coercions, as: :stringify



      # Build tuple from arguments.
      #   Translates keys into original schema names and stringify values.
      #
      # @param tuple [Hash] input arguments for directory #add and #modify
      #
      # @return [Hash]
      #
      # @note Directory#add will receive a hash with key :dn
      #
      # @api public
      def self.tuplify(tuple, matrix)
        fn = t(:rename_keys, matrix) >>
             t(:map_values, t(:identify_value)) >>
             t(:map_values, t(:stringify)) >>
             t(:prune)

        fn.call(tuple)
      end

      # remove keys with blank values
      #
      def self.prune(tuple)
        tuple.reject { |_k, v| v.nil? or v.empty? }
      end

      # Map from
      #
      # @todo Finish documentation
      #
      # @param val [Symbol,String]
      #
      # @example
      #   id_value(true) => 'TRUE'
      #   id_value('TRUE') => true
      #   id_value('peter hamilton') => 'peter hamilton'
      #
      # @return [Symbol,String,Boolean]
      #
      # @api public
      def self.identify_value(val)
        case val
        when ::Symbol, ::TrueClass, ::FalseClass
          VALUES_MAP.fetch(val, val)
        else
          VALUES_MAP.invert.fetch(val, val)
        end
      end

      # Ensure tuple values are strings
      #
      # @param value [Mixed]
      #
      # @return [String, Array<String>]
      #
      # @api public
      def self.stringify(value)
        case value
        when ::Numeric    then value.to_s
        when ::Enumerable then value.map(&:to_s)
        when ::Hash       then value.to_json
        when ::String     then value
        end
      end

      def self.to_hexidecimal(value)
        value.each_byte.map { |b| b.to_s(16) }.join #.force_encoding(Encoding::UTF_8)
      end

      def self.to_hex(values)
        t(:map_array, t(:to_hexidecimal)).call(values)
      end

      # def self.to_decimal(value)
      #   value.each_byte.map { |b| b.to_s(10) }.join.force_encoding(Encoding::UTF_8)
      # end

      def self.to_binary(values)
        t(:map_array, t(:to_base64)).call(values)
      end

      # @see https://en.wikipedia.org/wiki/List_of_file_signatures
      # @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Complete_list_of_MIME_types
      # @see https://github.com/sdsykes/fastimage/blob/master/lib/fastimage.rb
      #
      # @param value [String] UTF-8 encoded
      #
      def self.to_base64(value)
        mime =
          case value[0, 2]
          when "\xFF\xD8" then 'image/jpeg'
          # when 0x89.chr + 'P'
          when "\x89P"    then 'image/png'
          when 'BM'       then 'image/bitmap'
          when 'II', 'MM' then 'image/tiff'
          # when 0xff.chr + 0xfb.chr, 'ID'
          when "\xFF\xFBID" then 'audio/mpeg'
          when 'WA'         then 'audio/x-wav'
          else
            'application/octet-stream'
          end

        ::Base64.strict_encode64(value).prepend("data:#{mime};base64,")
      end

      # @todo
      #   submit patch to Transproc
      # @note
      #   LDAP stores boolean values as capitalised strings.
      #
      # @return [TrueClass, FalseClass]
      #
      def self.to_boolean(value)
        Transproc::Coercions::BOOLEAN_MAP.merge('TRUE' => true, 'FALSE' => false).fetch(value)
      end

      # The 18-digit Active Directory timestamps,
      # also named 'Windows NT time format','Win32 FILETIME or SYSTEMTIME' or NTFS file time.
      #
      # These are used in Microsoft Active Directory for
      # pwdLastSet, accountExpires, LastLogon, LastLogonTimestamp and LastPwdSet.
      #
      # The timestamp is the number of 100-nanoseconds intervals (1 nanosecond = one billionth of a second)
      # since Jan 1, 1601 UTC.
      #
      # Milliseconds are discarded (last 7 digits of the LDAP timestamp)
      #
      # @see ROM::LDAP::Types::Time
      #
      # @param value [String] time or integer
      #
      def self.to_time(value)
        unix_epoch_time = (Integer(value) / TEN_MILLION) - SINCE_1601
        ::Time.at(unix_epoch_time)
      rescue ArgumentError
        ::Time.parse(value).utc
      end


      def self.map_to_integers(tuples)
        t(:map_array, t(:to_integer)).call(tuples)
      end

      def self.map_to_symbols(tuples)
        t(:map_array, t(:to_symbol)).call(tuples)
      end

      # @return [Array<TrueClass, FalseClass>]
      #
      def self.map_to_booleans(values)
        t(:map_array, t(:to_boolean)).call(values)
      end

      def self.map_to_times(values)
        t(:map_array, t(:to_time)).call(values)
      end


      # Convert string to snake case.
      #
      # @param value [String]
      #
      # @return [String]
      #
      def self.to_underscore(value)
        Inflector.underscore(value.delete('= '))
      end

      # Function applied to Directory::Entry to format incoming attribute names.
      #
      # @api public
      def self.to_method_name(value)
        fn = t(:to_string) >> t(:to_underscore) >> t(:to_symbol)
        fn.call(value)
      end

    end
  end
end
