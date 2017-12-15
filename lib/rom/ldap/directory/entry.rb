require 'dry/equalizer'
require 'dry/core/cache'
require 'rom/ldap/functions'
require 'rom/ldap/directory/ldif'

using ::Compatibility

module ROM
  module LDAP
    class Directory
      class Entry
        module ClassMethods
          attr_reader :formatter

          def rename(key)
            formatter ? formatter[key] : key
          end

          def use_formatter(function)
            @formatter = function
          end

          # Set Entry.rename to use the default transformer proc.
          #
          # @api public
          def to_method_name!
            use_formatter ->(key) { LDAP::Functions.to_method_name(key) }
          end
        end

        extend ClassMethods
        extend Dry::Core::Cache

        include Dry::Equalizer(:to_h, :to_a, :to_str, :to_json, :to_ldif)

        def initialize(dn = nil, attributes = EMPTY_ARRAY)
          @dn = dn
          @source = {}
          @canonical = {}

          attributes.each do |key, value|
            store_source('dn', dn)
            store_source(key, value)
            store_canonical('dn', dn)
            store_canonical(key, value)
          end
        end

        attr_reader :dn
        attr_reader :source

        def [](key, alt = EMPTY_ARRAY)
          @canonical[rename(key)] || alt
        end
        alias fetch []

        # Prune unwanted keys from internal hashes.
        # Uses ::Compatibility#slice refinement unless Ruby >= 2.5.0
        #
        # @param keys [Array<Symbol, String>] Entry attributes to keep
        #
        # @return [self]
        #
        # @api public
        def select(*keys)
          source_keys = translation_map.fetch_values(*keys)
          @canonical  = @canonical.slice(*keys)
          @source     = @source.slice(*source_keys)
          self
        end

        def first(key)
          value = self[key]
          value&.first
        end

        def last(key)
          value = self[key]
          value&.last
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
        # Necessary for clean YAML output
        #
        def export
          @source.map { |k, v| { k.to_s => v.to_a.map(&:to_s) } }.reduce(&:merge)
        end

        def to_json
          export.to_json
        end

        def to_yaml
          export.to_yaml
        end

        # Print an LDIF string
        #
        def to_ldif
          LDIF.new(export).to_ldif
        end
        alias to_s to_ldif

        def hash
          @source.hash
        end

        def respond_to_missing?(*args)
          !!self[args.first]
        end

        def method_missing(method, *args, &block)
          value = self[method]
          return value unless value.empty?
          return @canonical.public_send(method, *args, &block) if @canonical.respond_to?(method)
          super
        end

        private

        # Build @source hash
        #
        # @api private
        def store_source(key, value)
          @source[key] = Array(value)
        end

        # Build @canonical hash of renamed keys
        #
        # @api private
        def store_canonical(key, value)
          @canonical[rename(key)] = Array(value)
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
