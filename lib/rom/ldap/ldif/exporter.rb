# frozen_string_literal: true

require 'rom/initializer'
require 'rom/ldap/functions'

module ROM
  module LDAP
    module LDIF
      # Export Entry objects as LDIF files.
      #
      # @param tuple [Array<Hash>]
      #
      # @api private
      class Exporter

        extend Initializer

        param :tuples, type: Types::Strict::Array.of(Types::Strict::Hash)

        # @return [String]
        #
        def to_ldif
          tuples.map { |tuple| create_entry(tuple) }.join(NEW_LINE)
        end

        private

        # @param tuple [Hash]
        #
        # @return [Array<String>]
        #
        def create_entry(tuple)
          ary = []
          tuple.each do |key, values|
            values.each { |value| ary << key_value_pair(key, value) }
          end
          ary << NEW_LINE
          ary
        end

        # @param key [String]
        # @param value [String]
        #
        # @return [String]
        #
        def key_value_pair(key, value)
          if /userpassword/i.match?(key)
            value = Functions[:to_base64].call(value)
            "#{key}:: #{value}"
          elsif value_is_binary?(value)
            value = Functions[:to_base64].call(value, strict: false)
            value = value.gsub(/#{NEW_LINE}/m, "#{NEW_LINE} ")
            "#{key}:: #{value}"
          else
            "#{key}: #{value}"
          end
        end

        #   jpegphoto:<file:///tmp/myphoto.jpg
        #   userpassword::qwerty
        #
        # @param value [String]
        #
        # @return [TrueClass, FalseClass]
        def value_is_binary?(value)
          return true if value.start_with?(':', '<')

          value.each_byte do |byte|
            return true if (byte < 32) || (byte > 126)
          end
          false
        end

      end
    end
  end
end
