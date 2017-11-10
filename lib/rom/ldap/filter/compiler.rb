require 'strscan'

module ROM
  module LDAP
    module Filter
      # TODO: replace complex class/instance level methods of parser and builder
      #  which are used in the dsl recursively with an abstract syntax tree object transformation.
      #
      #
      # @api private
      class Compiler
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

        # characters to escape
        escapes = %w[( ) & | = ! > < ~ * / \\]

        values = {
          :val_wild_card  => :'*',
          :val_true       => :'TRUE',
          :val_false      => :'FALSE',
        }

        operators = {
          :op_and      => :'&',
          :op_or       => :'|',
          :op_not      => :'!', # or :'~'
          :op_equal    => :'=',
          :op_gt_eq    => :'>=',
          :op_lt_eq    => :'<=',
          :op_prox     => :'~=',
          :op_ext      => :':=',
        }



        # @option :criteria [AST] Valid ast built by the dataset method chain
        #
        # @option :string [String] Existing ldap filter string
        #
        # @api private
        def initialize(string: nil, criteria: nil)
          @string  = string
          @scanner = StringScanner.new(string)
          @ast     = []

          if @scanner.peek(1) != '('
            raise InvalidError, 'must be wrapped in parentheses'
          end
        end

        attr_reader :scanner
        attr_reader :ast

        # (&(objectclass=person)(uidnumber=*)(mail=*))
        # ast => [
        #             # op             left                      right
        #           [ :'&', [
        #                   # op  left            right
        #                   [ :'=', 'objectclass',  'person']
        #                   [ :'=', 'uidnumber',    :'*'     ]
        #                   [ :'=', 'mail',         :'*'     ]
        #                 ],                                     nil
        #         ]
        #
        def parse
          if scanner.peek(2) == '(!'


          # <<  beginning_of_line?  charpos  check_until  concat  eos?
          # get_byte  getch    match?   matched?      peek  pointer   pos
          # post_match  reset  rest?      restsize  scan_full   search_full
          # skip_until  string=    unscan
          # []  bol?                check    clear        empty?  exist?
          # getbyte   inspect  matched  matched_size  peep  pointer=  pos=
          # pre_match   rest   rest_size  scan      scan_until  skip
          # string      terminate

            @ast << :not
          elsif scanner.peek(2) == '(&'
            binding.pry

            scanner.scan_until(/&/)       # => "(&"
            # scanner.scan %r"\(\w+=\w+\)"  # => "(objectclass=person)"

            scanner.scan %r"\((\w+)=(\w+)\)"  # => "(objectclass=person)"

            @ast << :and
          elsif scanner.peek(2) == '(|'
            @ast << :or
          end

          @ast
        end



        def to_ast
        end

        def to_s
        end

      end
    end
  end
end
