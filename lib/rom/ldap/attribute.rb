require 'rom/schema/attribute'

module ROM
  module Ldap
    # Extended schema attributes tailored for LDAP directories
    #
    # @api public
    class Attribute < ROM::Schema::Attribute


      # Return a new attribute marked as qualified
      #
      # @example
      #   users[:id].aliased(:user_id)
      #
      # @return [Ldap::Attribute]
      #
      # @api public
      def qualified(table_alias = nil)
        binding.pry
        return self if qualified?

        case sql_expr
        when Sequel::SQL::AliasedExpression, Sequel::SQL::Identifier
          type = meta(qualified: table_alias || true)
          type.meta(sql_expr: type.to_sql_name)
        else
          raise QualifyError, "can't qualify #{name.inspect} (#{sql_expr.inspect})"
        end
      end

    end

  end
end