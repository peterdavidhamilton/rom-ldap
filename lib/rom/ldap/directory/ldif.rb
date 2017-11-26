require 'dry/initializer'

module ROM
  module LDAP
    class Directory
      # Export Entry objects as LDIF files.
      #
      # @param tuple [Entry]
      #
      # @api private
      class LDIF
        extend Dry::Initializer

        param :tuple

        def to_ldif
          ary = []
          tuple.each do |key, values|
            values.each { |value| ary << key_value_pair(key, value) }
          end
          ary << NEW_LINE

          ary.join(NEW_LINE)
        end

        private

        def key_value_pair(key, value)
          if value_is_binary?(value)
            "#{key}:: #{new_value(value)}"
          else
            "#{key}: #{value}"
          end
        end

        def value_is_binary?(value)
          value = value.to_s
          return true if (value[0] == ':') || (value[0] == '<')
          value.each_byte do |byte|
            return true if (byte < 32) || (byte > 126)
          end
          false
        end

        def new_value(value)
          [value].pack('m').chomp.gsub(/\n/m, NEW_LINE)
        end
      end
    end
  end
end
