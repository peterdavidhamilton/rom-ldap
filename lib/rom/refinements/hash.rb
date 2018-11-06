#
# Backwards compatibility.
#
# Hash#slice method added to Ruby 2.5.0 release.
#
# Test environment gains #slice and #except from i18n gem
# @see i18n-0.9.1/lib/i18n/core_ext/hash.rb
#
module Compatibility
  refine ::Hash do
    if RUBY_VERSION.to_f < 2.5
      def slice(*keys)
        hash = {}
        keys.each { |key| hash[key] = fetch(key) if key?(key) }
        hash
      end
    end

    unless ::Hash.method_defined?(:except)
      def except(*less_keys)
        slice(*keys - less_keys)
      end
    end
  end
end
