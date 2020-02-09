# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class LDAP < RegexLexer

      title 'LDAP'
      desc 'the LDAP query filter format'
      tag 'ldap'


      EXTENSIBLE = /^([-;\w]*)(:dn)?(:(\w+|[.\w]+))?$/

      OPERATORS = '[~><:]?='

      CONSTRUCTORS = '&|\!|\|'


      state :root do



        # parentheses
        # rule /\s*[()]\s*/, Punctuation, :root
        rule %r{[()]}, Comment

        # constructors &, !, |
        # rule %r"&|\!|\|", Str::Symbol
        rule %r{[&\!\|]}, Str::Symbol




        # attribute name
        # rule /\w/, Keyword
        # rule %r"(\w)[~><:]?=", Name::Attribute

        # operators
        # rule /\s*[~><:]?=\s*/, Name::Function
        rule %r{([~><:]?=)}, Operator

        rule %r{[~><:]?=(\w+)}, Keyword

        # rule /\s*[~><:]?=\s*/ do
        #    groups Name::Function
        #    push :root
        #  end

        # numeric values
        # rule /\s*\d\s*/, Num::Integer


        # wild and boolean values
        rule %r{\*|TRUE|FALSE}, Name::Tag



        # string values
        # rule /\w/, Name::Variable
        # rule %r"=(\*)\)", Name::Variable
        # rule %r"=(\*)\)", Name::Tag


      end

      start do
        # this is run whenever a fresh lex is started
      end
    end
  end
end
