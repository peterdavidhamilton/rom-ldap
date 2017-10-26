# Don't load strscan until we need it.
require 'strscan'

# Rewritten as a callable class
class FilterParser


  ##


  # class << self
  #   private :new

  #   ##
  #   # Construct a filter tree from the provided string and return it.
  #   def parse(ldap_filter_string)
  #     new(ldap_filter_string).filter
  #   end
  # end



  # def initialize(str, filter_klass)
  # def initialize(filter_klass)

    # @filter = parse(StringScanner.new(str))

    # @new_filter_class = filter_klass

    # raise Net::LDAP::FilterSyntaxInvalidError, "Invalid filter syntax." unless @filter

    # abort 'Invalid filter syntax.' unless @filter
  # end

  # The constructed filter.
  # attr_reader :filter
  # attr_reader :new_filter_class

  # private


  extend Dry::Initializer

  param :filter_klass

  def call(str)
    # parse(StringScanner.new(str))
    scanner = StringScanner.new(str)
    parse_filter_branch(scanner) or parse_paren_expression(scanner)
  end

  ##
  # Parse the string contained in the StringScanner provided. Parsing
  # tries to parse a standalone expression first. If that fails, it tries
  # to parse a parenthesized expression.
  # def parse(scanner)
  #   parse_filter_branch(scanner) or parse_paren_expression(scanner)
  # end
  # private :parse




  ##
  # Join ("&") and intersect ("|") operations are presented in branches.
  # That is, the expression <tt>(&(test1)(test2)</tt> has two branches:
  # test1 and test2. Each of these is parsed separately and then pushed
  # into a branch array for filter merging using the parent operation.
  #
  # This method parses the branch text out into an array of filter
  # objects.
  def parse_branches(scanner)
    branches = []
    while branch = parse_paren_expression(scanner)
      branches << branch
    end
    branches
  end
  # private :parse_branches





  ##
  # Join ("&") and intersect ("|") operations are presented in branches.
  # That is, the expression <tt>(&(test1)(test2)</tt> has two branches:
  # test1 and test2. Each of these is parsed separately and then pushed
  # into a branch array for filter merging using the parent operation.
  #
  # This method calls #parse_branches to generate the branch list and then
  # merges them into a single Filter tree by calling the provided
  # operation.
  def merge_branches(op, scanner)
    filter = nil
    branches = parse_branches(scanner)

    if branches.size >= 1
      filter = branches.shift
      while not branches.empty?
        filter = filter.__send__(op, branches.shift)
      end
    end

    filter
  end
  # private :merge_branches




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

      if expr and scanner.scan(/\s*\)\s*/)
        expr
      end
    end
  end
  # private :parse_paren_expression

  ##
  # This parses a given expression inside of parentheses.
  def parse_filter_branch(scanner)
    # new_filter_class = ::ROM::LDAP::Dataset::Filter

    scanner.scan(/\s*/)
    if token = scanner.scan(/[-\w:.]*[\w]/)
      scanner.scan(/\s*/)
      if op = scanner.scan(/<=|>=|!=|:=|=/)
        scanner.scan(/\s*/)
        if value = scanner.scan(/(?:[-\[\]{}\w*.+\/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]|[^\x00-\x7F]|\\[a-fA-F\d]{2})+/u)
          # 20100313 AZ: Assumes that "(uid=george*)" is the same as
          # "(uid=george* )". The standard doesn't specify, but I can find
          # no examples that suggest otherwise.
          value.strip!
          case op
          when "="
            # Net::LDAP::Filter.eq(token, value)
            filter_klass.eq(token, value)
          when "!="
            filter_klass.ne(token, value)
          when "<="
            filter_klass.le(token, value)
          when ">="
            filter_klass.ge(token, value)
          when ":="
            filter_klass.ex(token, value)
          end
        end
      end
    end
  end

  # private :parse_filter_branch

end # class Net::LDAP::FilterParser
