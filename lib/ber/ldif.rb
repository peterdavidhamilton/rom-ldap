require 'dry/initializer'

module BER
  class LDIF
    extend Dry::Initializer

    param  :tuples
    option :version,  default: proc { 3 }
    option :comments, default: proc { [] }

    def to_ldif
      ary = []

      ary << "version: #{version}\n" if version
      ary += comments unless comments.empty?

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
