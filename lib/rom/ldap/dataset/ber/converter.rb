require 'rom/ldap/dataset/ber'

module ROM
  module LDAP
    class Dataset
      module BER
        class Converter

          extend ROM::Initializer

          param :op
          param :left
          param :right

          def call
            case op

            when :eq
              if right == WILDCARD # presence test
                left.to_s.to_ber_contextspecific(7)
              elsif right =~ /[*]/ # substring
                # Parsing substrings is a little tricky. We use String#split to
                # break a string into substrings delimited by the * (star)
                # character. But we also need to know whether there is a star at the
                # head and tail of the string, so we use a limit parameter value of
                # -1: "If negative, there is no limit to the number of fields
                # returned, and trailing null fields are not suppressed."
                #
                # 20100320 AZ: This is much simpler than the previous verison. Also,
                # unnecessary regex escaping has been removed.

                ary = right.split(/[*]+/, -1)

                if ary.first.empty?
                  first = nil
                  ary.shift
                else
                  first = unescape(ary.shift).to_ber_contextspecific(0)
                end

                if ary.last.empty?
                  last = nil
                  ary.pop
                else
                  last = unescape(ary.pop).to_ber_contextspecific(2)
                end

                seq = ary.map { |e| unescape(e).to_ber_contextspecific(1) }
                seq.unshift first if first
                seq.push last if last

                [left.to_s.to_ber, seq.to_ber].to_ber_contextspecific(4)
              else # equality
                [left.to_s.to_ber, unescape(right).to_ber].to_ber_contextspecific(3)
              end


            when :bineq
              # make sure data is not forced to UTF-8
              [left.to_s.to_ber, unescape(right).to_ber_bin].to_ber_contextspecific(3)


            when :ex
              seq = []

              # unless left =~ /^([-;\w]*)(:dn)?(:(\w+|[.\w]+))?$/
              unless left =~ EXTENSIBLE_REGEX
                abort "Bad attribute #{left}"
              end

              type, dn, rule = $1, $2, $4

              seq << rule.to_ber_contextspecific(1) unless rule.to_s.empty? # matchingRule
              seq << type.to_ber_contextspecific(2) unless type.to_s.empty? # type
              seq << unescape(right).to_ber_contextspecific(3) # matchingValue
              seq << "1".to_ber_contextspecific(4) unless dn.to_s.empty? # dnAttributes

              seq.to_ber_contextspecific(9)
            when :ge
              [left.to_s.to_ber, unescape(right).to_ber].to_ber_contextspecific(5)
            when :le
              [left.to_s.to_ber, unescape(right).to_ber].to_ber_contextspecific(6)
            when :ne
              [self.class.eq(left, right).to_ber].to_ber_contextspecific(2)
            when :and
              ary = [left.coalesce(:and), right.coalesce(:and)].flatten
              ary.map(&:to_ber).to_ber_contextspecific(0)
            when :or
              ary = [left.coalesce(:or), right.coalesce(:or)].flatten
              ary.map(&:to_ber).to_ber_contextspecific(1)
            when :not
              [left.to_ber].to_ber_contextspecific(2)
            end
          end

          private

          # Converts escaped characters (e.g., "\\28") to unescaped characters
          def unescape(right)
            # right.to_s.gsub(/\\([a-fA-F\d]{2})/) { [$1.hex].pack("U") }
            right.to_s.gsub(UNESCAPE_REGEX) { [$1.hex].pack("U") }
          end

        end


      end
    end
  end
end
