require 'transproc'
require 'base64'
require 'rom/support/inflector'

module ROM
  module LDAP
    # @api private
    module Functions
      extend Transproc::Registry

      import Transproc::Coercions
      import Transproc::ArrayTransformations
      import Transproc::HashTransformations

      # Build tuple from arguments.
      #   Translates keys into original schema names and stringify values.
      #
      # @param tuple [Hash] input arguments for directory #add and #modify
      #
      # @return [Hash]
      #
      # @note Directory#add will receive a hash with key :dn
      #
      # @api private
      def self.tuplify(tuple, matrix)
        fn = t(:rename_keys, matrix) >>
             t(:map_values, t(:identify_value)) >>
             t(:map_values, t(:stringify)) >> t(:reject_blank)

        fn.call(tuple)
      end

      # remove keys with blank values
      # nil values allow attribute to be deleted
      #
      def self.reject_blank(tuple)
        tuple.reject { |_k, v| v&.empty? }
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
      # @return [Mixed]
      #
      # @api private
      def self.identify_value(val)
        case val
        when ::Symbol, ::TrueClass, ::FalseClass, ::NilClass
          VALUES_MAP.fetch(val, val)
        else
          VALUES_MAP.invert.fetch(val, val)
        end
      end

      # Ensure tuple values are strings or nil
      #
      # @param value [Mixed]
      #
      # @return [String, NilClass]
      #
      # @api private
      def self.stringify(value)
        case value
        when ::Numeric    then value.to_s
        when ::Enumerable then value.map(&:to_s)
        when ::Hash       then value.to_json
        when ::String     then value
        else
          value
        end
      end

      # Compare Magic Bytes
      #
      # @see https://en.wikipedia.org/wiki/List_of_file_signatures
      # @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Complete_list_of_MIME_types
      # @see https://github.com/sdsykes/fastimage/blob/master/lib/fastimage.rb
      #
      # @param value [String] UTF-8 encoded
      #
      def self.mime_type(value)
        mime =
          case value[0, 2]
          when "\xFF\xD8".b
            'image/jpeg'
          when "\x89P".b
            'image/png'
          when 'BM'
            'image/bitmap'
          when 'II', 'MM'
            'image/tiff'
          when "\xFF\xFBID".b
            'audio/mpeg'
          when 'WA'
            'audio/x-wav'
          else
            'application/octet-stream'
          end
        to_base64(value).prepend("data:#{mime};base64,")
      end

      # Base64 encoded string, with optional new line characters.
      #
      # @return [String]
      #
      def self.to_base64(value, strict: true)
        if strict
          Base64.strict_encode64(value).chomp
        else
          # [value].pack('m').chomp
          Base64.encode64(value).chomp
        end
      end

      #
      #
      # @return [TrueClass, FalseClass]
      #
      def self.to_boolean(value)
        Transproc::Coercions::BOOLEAN_MAP.fetch(value.to_s.downcase)
      end

      # The 18-digit Active Directory timestamps, also named
      # 'Windows NT time format','Win32 FILETIME or SYSTEMTIME' or 'NTFS file time'.
      #
      # These are used in Microsoft Active Directory for
      # pwdLastSet, accountExpires, LastLogon, LastLogonTimestamp and LastPwdSet.
      #
      # The number of 100-nanoseconds intervals since 12:00 A.M. January 1st, 1601 (UTC).
      # NB:
      #   1 nanosecond = a billionth of a second
      #   Accurate to the nearest millisecond (7 digits)
      #
      # @see ROM::LDAP::Types::Time
      # @see https://ldapwiki.com/wiki/Microsoft%20TIME
      #
      # @param value [String] time or integer
      #
      # @return [Time] UTC formatted
      #
      def self.to_time(value)
        unix_epoch_time = (Integer(value) / TEN_MILLION) - SINCE_1601
        ::Time.at(unix_epoch_time).utc
      rescue ArgumentError
        ::Time.parse(value).utc
      end

      # @return [Array<String>]
      #
      def self.map_to_base64(values)
        t(:map_array, t(:to_base64)).call(values)
      end

      # @return [Array<Integer>]
      #
      def self.map_to_integers(tuples)
        t(:map_array, t(:to_integer)).call(tuples)
      end

      # @return [Array<Symbol>]
      #
      def self.map_to_symbols(tuples)
        t(:map_array, t(:to_symbol)).call(tuples)
      end

      # @return [Array<TrueClass, FalseClass>]
      #
      def self.map_to_booleans(values)
        t(:map_array, t(:to_boolean)).call(values)
      end

      # @return [Array<Time>]
      #
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
