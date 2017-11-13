require 'strscan'
require 'rom/ldap/filter/expression'

# TODO: replace the parser - which turns a string into expressions.
# with a composer to build an ast from a string,
# and a decomposer to turn an ast into a string.
module ROM
  module LDAP
    module Filter
      class Parser
        extend Dry::Initializer

        OPERATORS = {
          eq: '=',
          ne: '!=',
          ex: ':=',
          px: '~=',
          gt: '>',
          lt: '<',
          le: '<=',
          ge: '>=',
        }.freeze

        INTERSECTION_REGEX  = /\s*\&\s*/
        UNION_REGEX         = /\s*\|\s*/
        NEGATION_REGEX      = /\s*\!\s*/
        OPEN_REGEX          = /\s*\(\s*/
        CLOSE_REGEX         = /\s*\)\s*/
        ATTRIBUTE_REGEX     = /[-\w:.]*[\w]/
        WS_REGEX            = /\s*/
        UNESCAPE_REGEX      = /\\([a-fA-F\d]{2})/
        VALUE_REGEX         = /(?:[-\[\]{}\w*.+\/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]|[^\x00-\x7F]|\\[a-fA-F\d]{2})+/u

        OPERATOR_REGEX = Regexp.union(*OPERATORS.values)


        def call(str)
          scanner = StringScanner.new(str)
          parse_branch(scanner) || parse_expression(scanner)

          # op, left, right = parse_branch(scanner) || parse_expression(scanner)
          # Builder.new(op, left, right)

          # args = parse_branch(scanner) || parse_expression(scanner)
          # Builder.new(*args)
        end




        private

        def id_operator(str)
          OPERATORS.invert[str]
        end

        def parse_expression(scanner)
          if scanner.scan(OPEN_REGEX)
            expr = if scanner.scan(INTERSECTION_REGEX)
                     merge_branches(:&, scanner)
                   elsif scanner.scan(UNION_REGEX)
                     merge_branches(:|, scanner)
                   elsif scanner.scan(NEGATION_REGEX)
                     br = parse_expression(scanner)
                     ~br if br
                   else
                     parse_branch(scanner)
                   end

            expr if expr && scanner.scan(CLOSE_REGEX)
          end
        end

        def parse_branch(scanner)
          scanner.scan(WS_REGEX)
          if attribute = scanner.scan(ATTRIBUTE_REGEX)
            scanner.scan(WS_REGEX)
            if op = scanner.scan(OPERATOR_REGEX)
              scanner.scan(WS_REGEX)
              if value = scanner.scan(VALUE_REGEX)

                # [ id_operator(op), attribute, value ]

                args = [ id_operator(op), attribute, value ]
                Expression.new(*args)
              end
            end
          end
        end

        def parse_branches(scanner)
          branches = []
          while branch = parse_expression(scanner)
            branches << branch
          end
          branches
        end

        def merge_branches(op, scanner)
          branches = parse_branches(scanner)
          filter   = nil

          if branches.size >= 1
            filter = branches.shift
            filter = filter.__send__(op, branches.shift) until branches.empty?
          end

          filter
        end
      end
    end
  end
end
