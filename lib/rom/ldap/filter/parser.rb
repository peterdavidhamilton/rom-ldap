require 'strscan'
require 'rom/ldap/filter'

module ROM
  module LDAP
    module Filter
      class Parser
        extend Dry::Initializer

        param :filter_klass

        def call(str)
          scanner = StringScanner.new(str)
          parse_filter_branch(scanner) || parse_paren_expression(scanner)
          # filter = parse_filter_branch(scanner) or parse_paren_expression(scanner)
          # filter.to_s
        end

        private

        def parse_paren_expression(scanner)
          if scanner.scan(/\s*\(\s*/)
            expr = if scanner.scan(/\s*\&\s*/)
                     merge_branches(:&, scanner)
                   elsif scanner.scan(/\s*\|\s*/)
                     merge_branches(:|, scanner)
                   elsif scanner.scan(/\s*\!\s*/)
                     br = parse_paren_expression(scanner)
                     ~br if br
                   else
                     parse_filter_branch(scanner)
                   end

            expr if expr && scanner.scan(/\s*\)\s*/)
          end
        end

        def parse_filter_branch(scanner)
          scanner.scan(WS_REGEX)
          if token = scanner.scan(TOKEN_REGEX)

            scanner.scan(WS_REGEX)

            if op = scanner.scan(OPERATOR_REGEX)

              scanner.scan(WS_REGEX)

              if value = scanner.scan(VALUE_REGEX)

                value.strip!

                case op
                when EQUAL     then filter_klass.eq(token, value)
                when NOT_EQUAL then filter_klass.ne(token, value)
                when LESS_THAN then filter_klass.le(token, value)
                when MORE_THAN then filter_klass.ge(token, value)
                when EXT_COMP  then filter_klass.ex(token, value)
                end
              end
            end
          end
        end

        def parse_branches(scanner)
          branches = []
          while branch = parse_paren_expression(scanner)
            branches << branch
          end
          branches
        end

        def merge_branches(op, scanner)
          filter   = nil
          branches = parse_branches(scanner)

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
