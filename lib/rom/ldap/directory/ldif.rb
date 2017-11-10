require 'dry/initializer'

module ROM
  module LDAP
    class Directory
      # @param tuples [Array<Hash>]
      #
      # @option :version [Integer]
      #
      # @option :comments [String]
      #
      # @api private
      class LDIF
        extend Dry::Initializer

        param  :tuples

        def to_ldif(version: 3, comment: nil)
          ary = []

          ary << "version: #{version}\n"
          ary << comment if comment

          Array(tuples).each do |t|
            t.sort.each do |key, values|
              values.each do |value|
                ary << if value_is_binary?(value)
                         "#{key}:: #{new_value(value)}"
                       else
                         "#{key}: #{value}"
                       end
              end
            end
            ary << NEW_LINE
          end

          block_given? ? ary.map(&:yield) : ary.join(NEW_LINE)
        end

        def from_ldif(file)
          input = ::StringIO.new(file)
          binding.pry

        end

        private

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
