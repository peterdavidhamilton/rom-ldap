require 'ber/ldif'

# BER.formatter = ->(v) { ROM::LDAP::Functions.snake_case_symbol(v) }

module BER
  class Entity
    module ClassMethods
      def rename(key)
        return default_normaliser(key) if BER.formatter.nil?
        BER.formatter.call(key)
      end

      private

      def default_normaliser(key)
        key = key.to_s.downcase
        key = key.tr('-','')
        key = key[0..-2] if key[-1] == '='
        key.to_sym
      end

      def _load(entry)
        from_single_ldif_string(entry)
      end

      # def from_single_ldif_string(ldif)
      #   ds = LDIF.read_ldif(::StringIO.new(ldif))
      #   return nil if ds.empty?
      #   raise Error, "Too many LDIF entries" unless ds.size == 1
      #   entry = ds.to_entries.first
      #   return nil if entry.dn.nil?
      #   entry
      # end
    end

    extend ClassMethods

    def initialize(dn = nil, attributes = EMPTY_HASH)
      @dn, @source, @canonical = dn, {}, {}

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
      @canonical[rename(key)] || alt
    end

    alias fetch []

    def first(key)
      value = self[key]
      value.first if value
    end

    def last(key)
      value = self[key]
      value.last if value
    end

    def keys
      @source.keys
    end

    def attribute_names
      @canonical.keys
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

    def to_json
      @source.to_json
    end

    alias inspect to_s

    def hash
      @source.hash
    end

    def to_ldif
      BER::LDIF.new(self, comments: Time.now).to_ldif
    end

    def respond_to_missing?(*args)
      !!self[args.first]
    end

    def method_missing(method, *args, &block)
      value = self[method]
      return value if !value.empty?
      return @canonical.public_send(method, *args, &block) if @canonical.respond_to?(method)
      super
    end

    private

    def _dump(_depth)
      to_ldif
    end

    def rename(name)
      self.class.rename(name)
    end

    def store_source(key, value)
      @source[key] = Array(value)
    end

    def store_canonical(key, value)
      @canonical[rename(key)]  = Array(value)
    end

  end
end
