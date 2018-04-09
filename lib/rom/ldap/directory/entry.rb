require 'dry/equalizer'
require 'dry/core/cache'
require 'rom/ldap/functions'

using ::Compatibility
using ::LDIF

module ROM
  module LDAP
    class Directory
      class Entry
        module ClassMethods
          attr_reader :formatter

          def rename(key)
            formatter ? formatter[key] : key
          end

          # @see 'rom/ldap/extensions/compatible_entry_attributes'
          #
          # @example
          #   ROM::LDAP.load_extensions :compatible_entry_attributes
          #
          def use_formatter(function)
            @formatter = function
          end
        end

        extend ClassMethods
        extend Dry::Core::Cache

        include Dry::Equalizer(:to_h, :to_a, :to_str, :to_json, :to_ldif, :to_yaml)

        def initialize(dn, attributes = EMPTY_ARRAY)
          @dn        = dn
          @source    = build(dn, attributes)
          @canonical = build(dn, attributes, original: false)
        end

        attr_reader :dn
        attr_reader :source

        def [](key)
          @canonical[rename(key)]
        end

        def fetch(key, alt = EMPTY_ARRAY)
          @canonical.fetch(rename(key), alt)
        end

        # Prune unwanted keys from internal hashes. (update source then canonical)
        #
        # @param keys [Array <Symbol>] Entry attributes to keep
        #
        # @return [Entry]
        #
        # @api public
        def select(*keys)
          source_keys = keys.map { |k| translation_map[k] }
          @source    = @source.slice(*source_keys).freeze
          @canonical = @canonical.slice(*keys).freeze
          self
        end

        def first(key)
          fetch(key)&.first
        end

        def last(key)
          fetch(key)&.last
        end

        def keys
          @source.keys
        end

        def attribute_names
          @canonical.keys
        end

        def translation_map
          attribute_names.zip(keys).to_h
        end

        # Iterate over each canonical hash pair, or the values for a give attribute key.
        #
        # @param key [Symbol]
        #
        # @example
        def each(key = nil, &block)
          key.nil? ? @canonical.each(&block) : self[key].each(&block)
        end
        alias each_attribute each

        def to_h
          @canonical
        end
        alias to_hash to_h

        def to_a
          @canonical.to_a
        end
        alias to_ary to_a

        def to_str
          @canonical.inspect
        end
        alias inspect to_str

        # Return to first class objects from wrapped BER identified.
        # Necessary for clean export output.
        def encoded
          @source.map { |k, v| { k.to_s => Array(v).map(&:to_s) } }.reduce(&:merge)
        end

        def to_s
          encoded.to_ldif
        end

        def hash
          @source.hash
        end

        def respond_to_missing?(*args)
          !!self[args.first]
        end

        def method_missing(method, *args, &block)
          value = self[method]
          return value unless value.nil?
          return @canonical.public_send(method, *args, &block) if @canonical.respond_to?(method)
          super
        end

        private

        def build(dn, attributes, original: true)
          attributes.each_with_object({}) do |(attribute, value), hash|
            distinguished = original ? 'dn' : rename('dn')
            attribute     = original ? attribute : rename(attribute)
            hash[distinguished] = dn
            hash[attribute]     = value
          end.freeze
        end

        # Cache renamed key to improve performance two fold in benchmarks.
        #
        # @param key [String, Symbol]
        #
        # @api private
        def rename(key)
          fetch_or_store(key, self.class.formatter) { self.class.rename(key) }
        end
      end
    end
  end
end
