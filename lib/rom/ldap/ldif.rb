require 'rom/initializer'
#
# @see https://docs.oracle.com/cd/E10773_01/doc/oim.1014/e10531/ldif_appendix.htm
#
module ROM
  module LDAP
    #
    # LDAP Data Interchange Format (LDIF)
    #
    # Refines Array and Hash with #to_ldif method.
    #
    # @see Directory::Entry
    # @see Relation::Exporting
    #
    module LDIF
      # Export Entry objects as LDIF files.
      #
      # @param tuple [Entry]
      #
      # @api private
      class Exporter
        extend Initializer

        # Dataset
        #
        param :tuples, type: Types::Strict::Array.of(Types::Strict::Hash)

        # @return [String]
        #
        # @api private
        def to_ldif
          tuples.map { |tuple| create_entry(tuple) }.join(NEW_LINE)
        end

        private

        def create_entry(tuple)
          ary = []
          tuple.each do |key, values|
            values.each { |value| ary << key_value_pair(key, value) }
          end
          ary << NEW_LINE
          ary
        end

        # @api private
        def key_value_pair(key, value)
          if value_is_binary?(value)
            "#{key}:: #{new_value(value)}"
          else
            "#{key}: #{value}"
          end
        end

        # @api private
        def value_is_binary?(value)
          value = value.to_s
          return true if (value[0] == ':') || (value[0] == '<')

          value.each_byte do |byte|
            return true if (byte < 32) || (byte > 126)
          end
          false
        end

        # @api private
        def new_value(value)
          [value].pack('m').chomp.gsub(/\n/m, NEW_LINE)
        end
      end

      # Extend functionality of Hash class.
      #
      refine ::Hash do
        # Convert hash to LDIF format
        #
        # @return [String]
        #
        # @api public
        def to_ldif
          Exporter.new([self]).to_ldif
        end
      end

      # Extend functionality of Array class.
      #
      refine ::Array do
        # Convert array to LDIF format
        #
        # @return [String]
        #
        # @api public
        def to_ldif
          Exporter.new(self).to_ldif
        end
      end
    end
  end
end
