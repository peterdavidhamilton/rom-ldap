require 'rom/initializer'

module ROM
  module LDAP
    module LDIF
      # LDIF to importable tuples.
      #
      # @param ldif [String]
      #
      # @api private
      class Importer

        extend Initializer

        param :ldif, type: Types::Strict::String

        # @example =>
        #
        #   [{
        #                 :dn => "ou=users, dc=rom, dc=ldap",
        #                "ou" => "users",
        #       "objectClass" => "organizationalUnit"
        #   }]
        #
        # @return [Array<Hash>]
        #
        def to_tuples
          dataset.map do |entry|
            next if entry.any? { |l| l.match?(/^version/) }

            abort 'update statements not allowed' if entry.any? { |l| l.match?(/^changetype/) }

            tuple = parse(entry)

            block_given? ? yield(tuple) : tuple
          end.compact
        end

        private

        def dataset
          ldif
            .split(NEW_LINE)
            .reject(&method(:comment?))
            .chunk(&method(:divider?))
            .reject(&:first)
            .map(&:pop)
        end

        def comment?(line)
          line.match?(/^#/)
        end

        def divider?(line)
          line.eql?(EMPTY_STRING)
        end

        # @param entry [Array<String>]
        #
        # @return [Hash]
        #
        def parse(entry)
          entry.map(&method(:key_pair)).inject(&method(:merge))
        end

        #
        # @return [Hash]
        #
        def key_pair(line)
          _, key, _, value = line.match(LDIF_LINE_REGEX).to_a

          key = key.to_sym if key.eql?('dn')
          value = File.binread(Regexp.last_match(1)) if value.match(BIN_FILE_REGEX)
          value = Functions[:identify_value].call(value)

          { key => value }
        end

        def merge(original, additional)
          key, value = additional.to_a.first

          if original.key?(key)
            original[key] = [*original[key], value]
            original
          else
            original.merge(additional)
          end
        end

      end
    end
  end
end
