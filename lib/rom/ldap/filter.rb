module ROM
  module LDAP
    module Filter
      # OPERATORS_MAP = {
      #   :op_plus   => :+@,
      #   :op_minus  => :-@,
      #   :op_add    => :+,
      #   :op_sub    => :-,
      #   :op_pow    => :**,
      #   :op_mul    => :*,
      #   :op_div    => :/,
      #   :op_mod    => :%,
      #   :op_tilde  => :~,
      #   :op_cmp    => :<=>,
      #   :op_lshift => :<<,
      #   :op_rshift => :>>,
      #   :op_lt     => :<,
      #   :op_gt     => :>,
      #   :op_case   => :===,
      #   :op_equal  => :==,
      #   :op_apply  => :=~,
      #   :op_lt_eq  => :<=,
      #   :op_gt_eq  => :>=,
      #   :op_or     => :|,
      #   :op_and    => :&,
      #   :op_xor    => :^,
      #   :op_store  => :[]=,
      #   :op_fetch  => :[]
      # }

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
