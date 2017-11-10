require 'rom/ldap/directory/ldif'
require 'rom/ldap/functions'

module ROM
  module LDAP
    class Directory
      class Entity
        module ClassMethods
          attr_reader :formatter

          def rename(key)
            formatter ? formatter[key] : key
          end

          def use_formatter(function)
            @formatter = function
          end

          def to_method_name!
            if formatter.nil?
              use_formatter ->(key) { LDAP::Functions.to_method_name(key) }
            end
          end

          def from_ldif(ldif)
            LDIF.read_ldif(ldif)
          end

          alias _load from_ldif
        end

        extend ClassMethods

        def initialize(dn = nil, attributes = EMPTY_HASH)
          @dn = dn
          @source = {}
          @canonical = {}

          attributes.each do |key, value|
            store_source('dn', dn)
            store_source(key, value)
            store_canonical('dn', dn)
            store_canonical(key, value)
          end

          @source.freeze
          @canonical.freeze
        end

        attr_reader :dn
        attr_reader :source

        def [](key, alt = EMPTY_ARRAY)
          @canonical[self.class.rename(key)] || alt
        end

        alias fetch []

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

        def each(key = nil, &block)
          key.nil? ? @canonical.each(&block) : self[key].each(&block)
        end

        alias each_attribute each

        def to_h
          @canonical
        end

        alias to_hash to_h

        def to_s
          @canonical.inspect
        end

        alias inspect to_s

        def to_json
          @source.to_json
        end

        def hash
          @source.hash
        end

        def to_ldif(_ = nil)
          LDIF.new(self).to_ldif(comment: Time.now)
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

        alias _dump to_ldif

        def store_source(key, value)
          @source[key] = Array(value)
        end

        def store_canonical(key, value)
          @canonical[self.class.rename(key)] = Array(value)
        end
      end
    end
  end
end
