# require 'rom/ldap/dataset/ber/refinements'

module ROM
  module LDAP
    class Dataset
      # Basic Encoding Rules
      module BER


        # name , hex , decimal , type , desc
        [ '?', 0xa0, 160, '' ] # context-specific constructed 0, "and"
        [ '?', 0xa1, 161, '' ] # context-specific constructed 1, "or"
        [ '?', 0xa2, 162, '' ] # context-specific constructed 2, "not"
        [ '?', 0xa3, 163, '' ] # context-specific constructed 3, "equalityMatch"
        [ '?', 0xa4, 164, '' ] # context-specific constructed 4, "substring"
        [ '?', 0xa5, 165, '' ] # context-specific constructed 5, "greaterOrEqual"
        [ '?', 0xa6, 166, '' ] # context-specific constructed 6, "lessOrEqual"
        [ '?', 0xa9, 169, '' ] # context-specific constructed 9, "extensible comparison"

        [ '?', 0x80, 128, 'SubstringFilter' ] # context-specific primitive 0, SubstringFilter "initial"
        [ '?', 0x81, 129, 'SubstringFilter' ] # context-specific primitive 0, SubstringFilter "any"
        [ '?', 0x82, 130, 'SubstringFilter' ] # context-specific primitive 0, SubstringFilter "final"
        [ '?', 0x83, 131, '' ] # #ex: value=element
        [ '?', 0x84, 132, '' ] # #ex: dn='dn'
        [ '?', 0x87, 135, '' ] # context-specific primitive 7, "present"

      end
    end
  end
end
