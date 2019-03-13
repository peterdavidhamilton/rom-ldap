require 'rom/types'
require 'rom/ldap/functions'

module ROM
  module LDAP
    module Types
      include ROM::Types

      # protocols of ldap and ldaps only
      URI = Strict::String.constrained(format: LDAPURI_REGEX)

      # Something in parentheses
      Filter = Strict::String.constrained(format: /^\s*\(.*\)\s*$/)

      # empty string
      DN = Strict::String.constrained(format: DN_REGEX)

      #
      Direction = Strict::Symbol.constrained(included_in: %i[asc desc])

      #
      Scope = Strict::Integer.constrained(included_in: SCOPES)

      #
      Deref = Strict::Integer.constrained(included_in: DEREF_ALL)


      # @see Schema::Attribute read types
      #

      #
      # Single Values --------
      #


      # 1.3.6.1.4.1.1466.115.121.1.40
      #
      #   Are treated as transparent 8-bit bytes.
      #   They may, or may not, be printable or human readable.
      #   Typically used by passwords.
      #   Allows matchingRules of `octetStringMatch` and `octetStringOrderingMatch`.
      #
      Octet   = Constructor(String,  ->(v) { Functions[:to_hex][v][0] }).meta(octet: true)

      #
      Binary  = Constructor(String,  ->(v) { Functions[:to_binary].(v[0]) }).meta(binary: true)

      #
      String  = Constructor(String,  ->(v) { Functions[:stringify].(v[0]) })

      # @return [Integer]
      Integer = Constructor(Integer, ->(v) { Functions[:map_to_integers][v][0] })

      # @return [Symbol]
      Symbol  = Constructor(Symbol,  ->(v) { Functions[:map_to_symbols][v][0] })

      # @return [Time]
      Time    = Constructor(Time,    ->(v) { Functions[:map_to_times][v][0] })

      # @return [TrueClass, FalseClass]
      Bool    = Constructor(Bool,    ->(v) { Functions[:map_to_booleans][v][0] })

      # Jpeg    = Constructor(String,  Functions[:to_base64])
      Jpeg    = String.constructor(Functions[:to_base64])

      # Audio   = Constructor(String,  Functions[:to_base64])
      Audio   = String.constructor(Functions[:to_base64])


      # 1.3.6.1.4.1.1466.115.121.1.41
      #
      # A special format which uses UTF-8 encoding of ISO-10646 (Unicode)
      # separated by '$' used for generating printable labels or other output.
      # DOES allow extended characters e.g. é, Ø, å etc.
      # Allows matchingRules of `caseIgnoreListMatch` and `caseIgnoreListSubstringsMatch`.
      #
      # @return [Array<String>]
      Address = Constructor(String, ->(v) { v.split('$').map(&:strip) })

      #
      # Multiple Values --------
      #

      #
      Octets    = Array.constructor(Functions[:to_hex]).meta(octet: true)

      #
      Binaries  = Array.constructor(Functions[:to_binary]).meta(binary: true)

      # @return [Array<String>]
      # Strings   = Array.constructor(Functions[:stringify])
      Strings   = Constructor(Array, Functions[:stringify])

      # @return [Array<Integer>]
      Integers  = Array.constructor(Functions[:map_to_integers])

      # @return [Array<Symbol>]
      Symbols   = Array.constructor(Functions[:map_to_symbols])

      # @return [Array<Time>]
      Times     = Array.constructor(Functions[:map_to_times])

      # @return [Array<TrueClass, FalseClass>]
      Bools     = Array.constructor(Functions[:map_to_booleans])

      #
      Jpegs  = String.constructor(Functions[:to_base64])

      #
      # Special LDAP Read Types --------
      #


      # Addresses = Constructor(Array, ->(v) { v.map { |a| a.split('$').map(&:strip) }.first })

      # Jpeg  = String.constructor -> (v) { Functions[:to_base64][v] }

    end
  end
end
