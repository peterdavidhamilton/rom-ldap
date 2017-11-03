require 'ber/converter'

  # OPERATORS_MAP = {
  #   :op_plus   => :+@,
  #   :op_minus  => :-@,
  #   :op_add    => :+,
  #   :op_sub    => :-,
  #   :op_pow    => :**,
  #   :op_mul    => :*,
  #   :op_div    => :/,
  #   :op_mod    => :%,
  #   :op_tilde  => :~,
  #   :op_cmp    => :<=>,
  #   :op_lshift => :<<,
  #   :op_rshift => :>>,
  #   :op_lt     => :<,
  #   :op_gt     => :>,
  #   :op_case   => :===,
  #   :op_equal  => :==,
  #   :op_apply  => :=~,
  #   :op_lt_eq  => :<=,
  #   :op_gt_eq  => :>=,
  #   :op_or     => :|,
  #   :op_and    => :&,
  #   :op_xor    => :^,
  #   :op_store  => :[]=,
  #   :op_fetch  => :[]
  # }


module ROM
  module LDAP
    class Dataset
      module Filter
        class Builder
          module InstanceMethods

            def &(filter)
              self.class.join(self, filter)
            end

            def |(filter)
              self.class.intersect(self, filter)
            end

            def ~@
              self.class.negate(self)
            end

            def to_raw_rfc2254
              case op
              when :ne
                "!(#{left}=#{right})"
              when :eq, :bineq
                "#{left}=#{right}"
              when :ex
                "#{left}:=#{right}"
              when :ge
                "#{left}>=#{right}"
              when :le
                "#{left}<=#{right}"
              when :and
                "&(#{left.to_raw_rfc2254})(#{right.to_raw_rfc2254})"
              when :or
                "|(#{left.to_raw_rfc2254})(#{right.to_raw_rfc2254})"
              when :not
                "!(#{left.to_raw_rfc2254})"
              end
            end


            def to_rfc2254
              "(#{to_raw_rfc2254})"
            end

            alias_method :to_s, :to_rfc2254

            def to_ber
              BER::Converter.new(op, left, right).call
            end


            def execute(&block)
              case op
              when :eq
                if right == WILDCARD
                  yield :present, left
                elsif right.index WILDCARD
                  yield(:substrings, left, right)
                else
                  yield(:equalityMatch, left, right)
                end
              when :ge
                yield(:greaterOrEqual, left, right)
              when :le
                yield(:lessOrEqual, left, right)
              when :or, :and
                yield(op, (left.execute(&block)), (right.execute(&block)))
              when :not
                yield(op, (left.execute(&block)))
              end || EMPTY_ARRAY
            end



            def coalesce(operator)
              if op == operator
                [left.coalesce(operator), right.coalesce(operator)]
              else
                [self]
              end
            end



            def match(entry)
              case op
              when :eq
                if right == WILDCARD
                  l = entry[left] and l.length > 0
                else
                  l = entry[left] and l = Array(l) and l.index(right)
                end
              else
                abort "Unknown filter type in match: #{op}"
              end
            end
          end

        end
      end
    end
  end
end
