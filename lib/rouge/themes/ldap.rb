# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Themes
    class LDAP < CSSTheme
      name 'ldap'

      style Text, :fg => :fg0, :bg => :bg0
      style Error, :fg => :red, :bg => :bg0, :bold => true
      style Comment, :fg => :gray, :italic => true

      style Comment::Preproc, :fg => :aqua

      style Name::Tag, :fg => :red

      style Operator,
            Punctuation, :fg => :fg0

      style Generic::Inserted, :fg => :green, :bg => :bg0
      style Generic::Deleted, :fg => :red, :bg => :bg0
      style Generic::Heading, :fg => :green, :bold => true

      style Keyword, :fg => :red
      style Keyword::Constant, :fg => :purple
      style Keyword::Type, :fg => :yellow

      style Keyword::Declaration, :fg => :orange

      style Literal::String,
            Literal::String::Interpol,
            Literal::String::Regex, :fg => :green, :italic => true

      style Literal::String::Escape, :fg => :orange

      style Name::Namespace,
            Name::Class, :fg => :aqua

      style Name::Constant, :fg => :purple

      style Name::Attribute, :fg => :green

      style Literal::Number, :fg => :purple

      style Literal::String::Symbol, :fg => :blue

    end
  end
end
