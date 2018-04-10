require 'dry/equalizer'
require 'dry/core/cache'
require 'rom/ldap/functions'

using ::Compatibility
using ::LDIF

module ROM
  module LDAP
    class Directory
      #
      # Initialised by PDU#parse_search_return
      #
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

        extend Dry::Core::Cache
        extend ClassMethods

        include Dry::Equalizer(:to_h, :to_a, :to_str)

        attr_reader :dn
        attr_reader :source
        attr_reader :attributes

        def initialize(dn, attributes = EMPTY_ARRAY)
          @dn         = dn.to_s
          @attributes = attributes.push(['dn', [dn]])
          @source     = build
          @canonical  = build(original: false)
        end

        def [](key)
          @canonical[rename(key)]
        end

        def fetch(key, alt = EMPTY_ARRAY)
          @canonical.fetch(rename(key), alt)
        end

        # FIXME: This is destructive and breaks if select is called twice
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
          source.keys
        end

        def attribute_names
          @canonical.keys
        end

        def translation_map
          attribute_names.zip(keys).to_h
        end

        # Iterate over canonical attributes, or the values for a give attribute.
        #
        # @param key [Symbol] canonical attribute name
        #
        # @example entry.each(:object_class) { |e| puts e }
        #
        def each(key = nil, &block)
          key ? fetch(key).each(&block) : @canonical.each(&block)
        end
        alias each_attribute each

        # Iterate over canonical attributes, or the values for a give attribute.
        #
        # @param key [Symbol] canonical attribute name
        #
        # @example entry.map(:object_class, &:to_sym)
        #
        def map(key = nil, &block)
          key ? fetch(key).map(&block) : @canonical.map(&block)
        end

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

        def to_s
          source.to_ldif
        end

        def hash
          source.hash
        end

        def method_missing(method, *args, &block)
          value = self[method]
          return value unless value.nil?
          return @canonical.public_send(method, *args, &block) if @canonical.respond_to?(method)
          super
        end

        private

        # Merge dn with attributes as arrays of strings.
        #
        # @return [Hash]
        #
        # @api private
        def build(original: true)
          attributes.each_with_object({}) do |(attr, vals), h|
            h[original ? attr.to_s : rename(attr)] = vals.map(&:to_s)
          end
        end

        def respond_to_missing?(name, _include_private = false)
          !!self[name]
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
