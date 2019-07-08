require 'dry/core/cache'
require 'dry/equalizer'
require 'rom/initializer'
require 'rom/support/memoizable'
require 'rom/ldap/functions'


module ROM
  module LDAP
    class Directory
      # A Hash-like object wrapping the DN and attributes returned by the server.
      #   Contains the canonical attributes hash and a formatted version.
      #
      # Exposes methods #fetch, #first, #each_value and #include?.
      # All other method calls are forwarded to the formatted tuple.
      #
      # @see Directory#query
      #
      # @api public
      class Entry

        extend Initializer
        extend Dry::Core::Cache

        include Dry::Equalizer(:dn, :attributes, :canonical, :formatted)
        include Memoizable

        # @see Dataset::Persistence
        #
        # BER format converted to primitive String
        # Accessed when iterating over dataset during #modify and #delete
        #
        param :dn, proc(&:to_s), type: Types::Strict::String

        # Array of Array of Strings
        param :attributes, type: Types::Strict::Array, reader: :private


        # Retrieve values for a given attribute.
        #
        # @see Directory::Root
        #
        # @return [Array<String>]
        #
        # @param key [String, Symbol]
        #
        # @api public
        def fetch(key)
          formatted.fetch(rename(key), canonical[key])
        end
        alias [] fetch

        # Find the first (only) value for an attribute.
        #
        # @see Directory::Root
        #
        # @param [Symbol, String] key Attribute name.
        #
        # @return [String]
        #
        # @api public
        def first(key)
          fetch(key)&.first
        end

        # Iterate over the values of a given attribute.
        #
        # @param key [Symbol] canonical attribute name
        #
        # @example
        #
        #   entry.each_value(:object_class, &:to_sym)
        #   entry.each_value(:object_class) { |o| o.to_sym }
        #
        # @api public
        def each_value(key, &block)
          fetch(key).map(&block)
        end


        # Mostly used by the test suite.
        #
        # @example
        #
        #   expect(relation.first).to include(attr: %w[val1 val2])
        #
        # @param tuple [Hash] keys and array of values
        #
        # @return [TrueClass]
        #
        # @api public
        def include?(tuple)
          tuple.flat_map { |attr, vals| vals.map { |v| fetch(attr).include?(v) } }.all?
        rescue NoMethodError
          false
        end


        # Compatibility method with Ruby < 2.5
        #
        # @see Relation::Reading#pluck
        #
        # @return [Hash]
        #
        # @api public
        def slice(*keys)
          formatted.select { |k,v| keys.include?(k) }
        end


        # Defer to enumerable hash methods before entry values.
        #
        #
        def method_missing(meth, *args, &block)
          formatted.send(meth, *args, &block) if formatted.respond_to?(meth) || super
        end

        # @return [String]
        #
        def inspect
          %(#<#{self.class} #{dn.empty? ? 'rootDSE' : dn} />).freeze
        end


        private

        # @param meth [Symbol]
        #
        # @return [TrueClass, FalseClass]
        #
        def respond_to_missing?(meth, include_private = false)
          formatted.respond_to?(meth) || super
        end

        # Cache renamed key to improve performance two fold in benchmarks.
        #
        # @param key [String, Symbol]
        #
        # @api private
        def rename(key)
          fetch_or_store(key) { LDAP.formatter[key] }
        end

        # Convert keys of the canonical tuple using the chosen formatting proc.
        #
        def formatted
          Functions[:map_keys, LDAP.formatter][canonical]
        end

        # DN combined with attributes array
        #
        # @return [Array]
        #
        # @api private
        def with_dn
          attributes.dup.sort.unshift(['dn', dn])
        end

        # Create canonical tuple
        #
        # @example
        #
        #   # => { 'dn' => [''], 'objectClass' => ['', ''] }
        #
        # @return [Hash] canonical camelCase keys ordered alphabetically
        #
        # Dataset#export
        #
        def canonical
          stringify_keys[stringify_values[with_dn]]
        end

        # Covert hash keys to strings.
        #
        # @return [Proc]
        #
        # @api private
        def stringify_keys
          Functions[:map_keys, Functions[:to_string]]
        end

        # Convert hash whose values are arrays of strings.
        #
        # @return [Proc]
        #
        # @api private
        def stringify_values
          Functions[:map_values, Functions[:map_array, Functions[:to_string]]]
        end

        memoize :canonical, :formatted
      end
    end
  end
end
