# frozen_string_literal: true

module ROM
  module LDAP
    # Proc that returns input value.
    #
    DEFAULT_FORMATTER = ->(v) { v }

    # Set/Reset the formatting proc
    #
    # @param func [Proc] Callable object
    #
    def self.use_formatter(func = nil)
      @formatter = func
    end

    # @see 'rom/ldap/extensions/compatibility'
    #
    # @example
    #   ROM::LDAP.load_extensions :compatibility
    #
    def self.formatter
      @formatter || DEFAULT_FORMATTER
    end
  end
end
