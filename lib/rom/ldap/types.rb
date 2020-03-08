# rubocop:disable Style/AsciiComments

require 'rom/types'
require 'rom/ldap/functions'

module ROM
  module LDAP
    module Types
      include ROM::Types

      # Protocol ldap(s) only
      #
      # @return [Dry::Types::Constrained]
      #
      # @api public
      URI = Strict::String.constrained(format: LDAPURI_REGEX)

      # Something in parentheses
      #
      # @return [Dry::Types::Constrained]
      #
      # @api public
      Filter = Strict::String.constrained(format: FILTER_REGEX)

      #
      # @return [Dry::Types::Constrained]
      #
      # @api public
      DN = Strict::String.constrained(format: DN_REGEX)

      # @return [Dry::Types::Constrained]
      #
      # @api public
      Direction = Strict::Symbol.constrained(included_in: %i[asc desc])

      # @return [Dry::Types::Constrained]
      #
      # @api public
      Scope = Strict::Integer.constrained(included_in: SCOPES)

      # @return [Dry::Types::Constrained]
      #
      # @api public
      Deref = Strict::Integer.constrained(included_in: DEREF_ALL)

      # Abstraction of LDAP constructors and operators
      #
      # @return [Dry::Types::Constrained]
      #
      # @api public
      Abstract = Strict::Symbol.constrained(included_in: ABSTRACTS)

      # Compatible filter fields (formatters may symbolise)
      #
      # @return [Dry::Types::Sum::Constrained]
      #
      # @api public
      Field = Strict::String | Strict::Symbol

      # Compatible filter values (including wildcard abstraction)
      #
      # @return [Dry::Types::Sum::Constrained]
      #
      # @api public
      Value = Strict::String | Strict::Integer | Strict::Float | Strict::Symbol.constrained(included_in: %i[wildcard])

      # @example => "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD...."
      #
      # @return [String]
      #
      # @api public
      Media = Constructor(String,  ->(v) { Functions[:mime_type].call(v[0]) })

      #     1.3.6.1.4.1.1466.115.121.1.41
      #
      #     A special format which uses UTF-8 encoding of ISO-10646 (Unicode)
      #     separated by '$' used for generating printable labels or other output.
      #     DOES allow extended characters e.g. é, Ø, å etc.
      #     Allows matchingRules of `caseIgnoreListMatch` and `caseIgnoreListSubstringsMatch`.
      #
      # @return [Array<String>]
      #
      # @api public
      Address = Constructor(Array, ->(v) { v.split('$').map(&:strip) })

      #
      # Single Values --------
      #
      # @see Schema::Attribute read types

      # @return [String]
      #
      # @api public
      String = Constructor(String, ->(v) { Functions[:stringify].call(v[0]) })

      # @return [Integer]
      #
      # @api public
      Integer = Constructor(Integer, ->(v) { Functions[:map_to_integers][v][0] })

      # @return [Symbol]
      #
      # @api public
      Symbol = Constructor(Symbol, ->(v) { Functions[:map_to_symbols][v][0] })

      # @return [Time]
      #
      # @api public
      Time = Constructor(Time, ->(v) { Functions[:map_to_times][v][0] })

      # @overload [ROM::Types::Bool]
      #
      # @return [TrueClass, FalseClass]
      #
      # @api public
      Bool = Constructor(Bool, ->(v) { Functions[:map_to_booleans][v][0] })

      # @return [String]
      #
      # @api public
      Binary = Constructor(String, ->(v) { Functions[:map_to_base64][v][0] }).meta(binary: true)

      #
      # Multiple Values --------
      #

      # @return [Array<String>]
      #
      # @api public
      Strings = Constructor(Array, Functions[:stringify])

      # @return [Array<Integer>]
      #
      # @api public
      Integers = Constructor(Array, Functions[:map_to_integers])

      # @return [Array<Symbol>]
      #
      # @api public
      Symbols = Constructor(Array, Functions[:map_to_symbols])

      # @return [Array<Time>]
      #
      # @api public
      Times = Constructor(Array, Functions[:map_to_times])

      # @return [Array<TrueClass, FalseClass>]
      #
      # @api public
      Bools = Constructor(Array, Functions[:map_to_booleans])

      # @return [Array<String>]
      #
      # @api public
      Binaries = Constructor(Array, Functions[:map_to_base64]).meta(binary: true)
    end
  end
end

# rubocop:enable Style/AsciiComments
