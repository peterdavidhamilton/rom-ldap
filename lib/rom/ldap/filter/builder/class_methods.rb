require 'rom/ldap/filter/parser'
require 'ber/parser'

module ROM
  module LDAP
    module Filter
      class Builder
        module ClassMethods
          def self.included(klass)
            klass.class_eval do
              private :new
            end
          end

          def parse_ber(ber)
            binding.pry
            meth, attribute, value = BER::Parser.new(ber).call
            new(meth, attribute, value)
          end

          # def construct(ldap_filter_string)
          #   Filter::Parser.new(self).call(ldap_filter_string)
          # end

          def eq(attribute, value)
            new(:eq, attribute, value)
          end

          def equals(attribute, value)
            new(:eq, attribute, escape(value))
          end

          def begins(attribute, value)
            new(:eq, attribute, escape(value) + WILDCARD)
          end

          def ends(attribute, value)
            new(:eq, attribute, WILDCARD + escape(value))
          end

          def contains(attribute, value)
            new(:eq, attribute, WILDCARD + escape(value) + WILDCARD)
          end

          def bineq(attribute, value)
            new(:bineq, attribute, value)
          end

          def ex(attribute, value)
            new(:ex, attribute, value)
          end

          def ne(attribute, value)
            new(:ne, attribute, value)
          end

          def ge(attribute, value)
            new(:ge, attribute, value)
          end

          def le(attribute, value)
            new(:le, attribute, value)
          end

          def join(left, right)
            new(:and, left, right)
          end

          def intersect(left, right)
            new(:or, left, right)
          end

          # def negate(filter)
          #   new(:not, filter, nil)
          # end

          # def present?(attribute)
          #   eq(attribute, WILDCARD)
          # end

          # alias present present?
          # alias pres present?

          # Escape a string for use in an LDAP filter
          #
          def escape(string)
            string.gsub(ESCAPE_REGEX) { |char| '\\' + ESCAPES[char] }
          end


        end
      end
    end
  end
end
