# frozen_string_literal: true

require 'rom/mapper_compiler'

module ROM
  module LDAP
    class MapperCompiler < ROM::MapperCompiler
      # def visit_attribute(node)
      #   name, _, meta_options = node

      #   if meta_options[:wrapped]
      #     [name, from: meta_options[:alias]]
      #   else
      #     [name]
      #   end
      # end
    end
  end
end
