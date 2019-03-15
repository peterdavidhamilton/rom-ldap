
require 'rouge/util'
require 'rouge/token'
require 'rouge/theme'
require 'rouge/themes/gruvbox'
require 'rouge/formatter'
require 'rouge/formatters/terminal256'
require 'rouge/lexer'
require 'rouge/regex_lexer'
# require 'rouge/lexers/sql'

class LDAPLexer < Rouge::RegexLexer

  title 'LDAP'
  desc 'the LDAP query filter format (https://)'
  tag 'ldap'


  state :root do
    # parentheses
    rule /\s*[()]\s*/, Punctuation, :root

    # constructors
    rule /&|\!|\|/, Str::Symbol

    # attribute name
    rule /\w/, Keyword

    # operators
    rule /\s*[~><:]?=\s*/, Name::Function

    # rule /\s*[~><:]?=\s*/ do
    #    groups Name::Function
    #    push :root
    #  end

    # numeric values
    rule /\s*\d\s*/, Num::Integer

    # wild and boolean values
    rule /\*|TRUE|FALSE/, Str::Other

    # string values
    rule /\w/, Comment
  end

  start do
    # this is run whenever a fresh lex is started
  end
end




module Dry
  module Monitor
    module LDAP
      module Colorizers
        class Rouge
          attr_reader :formatter
          attr_reader :lexer

          def initialize(theme)
            @formatter = ::Rouge::Formatters::Terminal256.new(theme || ::Rouge::Themes::Gruvbox.new)
            # @lexer = ::Rouge::Lexers::SQL.new
            @lexer = LDAPLexer.new
          end

          def call(string)
            formatter.format(lexer.lex(string))
          end
        end
      end
    end
  end
end




