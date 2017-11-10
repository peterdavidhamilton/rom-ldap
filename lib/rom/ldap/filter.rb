module ROM
  module LDAP
    module Filter
    end

    EQUAL     = '='.freeze
    NOT_EQUAL = '!='.freeze
    LESS_THAN = '<='.freeze
    MORE_THAN = '>='.freeze
    EXT_COMP  = ':='.freeze

    OPERATOR_REGEX = Regexp.union(EQUAL, NOT_EQUAL, LESS_THAN, MORE_THAN, EXT_COMP).freeze

    TOKEN_REGEX      = /[-\w:.]*[\w]/
    WS_REGEX         = /\s*/
    UNESCAPE_REGEX   = /\\([a-fA-F\d]{2})/
    VALUE_REGEX = /(?:[-\[\]{}\w*.+\/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]|[^\x00-\x7F]|\\[a-fA-F\d]{2})+/u

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
