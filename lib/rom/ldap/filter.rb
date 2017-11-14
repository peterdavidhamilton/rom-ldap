module ROM
  module LDAP
    module Filter

      CONSTRUCTORS = {
        con_and: '&', # intersection
        con_or:  '|', # union
        con_not: '!', # negation
      }.freeze

      # NB: Order of values effects regexp
      OPERATORS = {
        op_prox:  '~=',
        op_ext:   ':=',
        op_gt_eq: '>=',
        op_lt_eq: '<=',
        op_gt:    '>',
        op_lt:    '<',
        op_equal: '='
      }.freeze

      VALUES = {
        :wildcard => '*',
        true      => 'TRUE',
        false     => 'FALSE'
      }.freeze

      WS_REGEX    = /\s*/
      OPEN_REGEX  = /\s*\(\s*/
      CLOSE_REGEX = /\s*\)\s*/
      AND_REGEX   = /\s*\&\s*/
      OR_REGEX    = /\s*\|\s*/
      NOT_REGEX   = /\s*\!\s*/
      ATTR_REGEX  = /[-\w:.]*[\w]/
      VAL_REGEX   = /(?:[-\[\]{}\w*.+\/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]|[^\x00-\x7F]|\\[a-fA-F\d]{2})+/u
      OP_REGEX    = Regexp.union(*OPERATORS.values)
      BRANCH_REGEX = Regexp.union(OR_REGEX, AND_REGEX)


      # @param val [Symbol,String]
      #
      # @example
      #   id_constructor(:con_and) => '&'
      #   id_constructor('&') => :con_and
      #
      # @return [String,Symbol]
      #
      # @api private
      def id_constructor(val)
        val.is_a?(Symbol) ? CONSTRUCTORS[val] : CONSTRUCTORS.invert[val]
      end

      # @param val [Symbol,String]
      #
      # @example
      #   id_operator(:op_gt_eq) => '>='
      #
      # @return [String,Symbol]
      #
      # @api private
      def id_operator(val)
        val.is_a?(Symbol) ? OPERATORS[val] : OPERATORS.invert[val]
      end

      # @param sym [Symbol,String]
      #
      # @example
      #   id_value(true) => 'TRUE'
      #   id_value('TRUE') => true
      #   id_value('peter hamilton') => 'peter hamilton'
      #
      # @return [Symbol,String,Boolean]
      #
      # @api private
      def id_value(val)
        if val.is_a?(Symbol)
          VALUES.fetch(val, val)
        else
          VALUES.invert.fetch(val, val)
        end
      end


    end
  end
end
