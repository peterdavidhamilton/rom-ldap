#
# Backwards compatibility. Hash#slice method added to Ruby 2.5.0 release.
#
module Compatibility
  #
  # Hash#slice method added to Ruby 2.5.0 release.
  #
  refine ::Hash do
    if RUBY_VERSION.to_i < 2.5
      def slice(*keys)
        hash = {}
        keys.each { |key| hash[key] = fetch(key) if key?(key) }
        hash
      end
    end
  end
end
