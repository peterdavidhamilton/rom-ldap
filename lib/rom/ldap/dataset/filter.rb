module ROM
  module LDAP
    class Dataset

      module Filter
        # method      | aliases          | RFC-2254 filter string
        # ______________________________________________________________________
        # :filter     |                  |
        # :present    | :has, :exists    | 'column=*'
        # :lte        | :below,          | 'column<=value'
        # :gte        | :above,          | 'column>=value'
        # :begins     | :prefix,         | 'column=value*'
        # :ends       | :suffix,         | 'column=*value'
        # :within     | :between, :range | '&(('column>=value')('column<=value'))'
        # :outside    |                  | '~&(('column>=value')('column<=value'))'
        # :equals     | :where,          | 'column=value'
        # :not        | :missing,        | '~column=value'
        # :contains   | :matches,        | 'column=*value*'
        # :exclude    |                  | '~column=*value*'
        # :extensible | :ext             | 'column:=value'
        #
      end

      EQUAL     = '='.freeze
      NOT_EQUAL = '!='.freeze
      LESS_THAN = '<='.freeze
      MORE_THAN = '>='.freeze
      EXT_COMP  = ':='.freeze
      WILDCARD  = '*'.freeze


      OPERATOR_REGEX = Regexp.union(EQUAL, NOT_EQUAL, LESS_THAN, MORE_THAN, EXT_COMP).freeze

      TOKEN_REGEX      = %r"[-\w:.]*[\w]".freeze
      WS_REGEX         = /\s*/.freeze
      EXTENSIBLE_REGEX = /^([-;\w]*)(:dn)?(:(\w+|[.\w]+))?$/.freeze
      UNESCAPE_REGEX   = /\\([a-fA-F\d]{2})/.freeze

      # VALUE_REGEX    =  /( ?:[-\[\]{}\w*.+\/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]  |  [^\x00-\x7F]  |  \\[a-fA-F\d]{2}  )+/u.freeze
      VALUE_REGEX      =  /(?:[-\[\]{}\w*.+\/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]|[^\x00-\x7F]|#{UNESCAPE_REGEX})+/u.freeze


      ESCAPES = {
        "\0" => '00', # NUL      = %x00 ; null character
        '*'  => '2A', # ASTERISK = %x2A ; asterisk (WILDCARD)
        '('  => '28', # LPARENS  = %x28 ; left parenthesis ("(")
        ')'  => '29', # RPARENS  = %x29 ; right parenthesis (")")
        '\\' => '5C', # ESC      = %x5C ; esc (or backslash) ("\")
      }.freeze


      ESCAPE_REGEX = Regexp.new('[' + ESCAPES.keys.map { |e| Regexp.escape(e) }.join + ']')


    end
  end
end
