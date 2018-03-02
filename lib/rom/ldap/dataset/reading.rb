using ::LDIF

module ROM
  module LDAP
    class Dataset
      module Reading

        # NB: Not the same as Relation#fetch!!
        #
        # Find by Distinguished Name(s)
        #
        # @param dns [String, Array<String>]
        #
        # @return [Dataset]
        #
        # @api public
        def fetch(dns)
          with(entries: Array(dns).flat_map { |dn| directory.by_dn(dn) })
        end


        # Validate the password against the filtered user.
        #
        # @param password [String]
        #
        # @return [Boolean]
        #
        # @api public
        def bind(password)
          directory.bind_as(filter: query_ast, password: password)
        end

        # Handle different string output formats.
        #
        # @return [String]
        #
        # @api
        def export(format:, keys:)
          if count > 1
            map { |entry| entry.select(*keys).encoded }.__send__(format)
          else
            first.select(*keys).encoded.__send__(format)
          end
        end

        # Unrestricted count of every entry under the base with base entry deducted.
        #
        # @return [Integer]
        #
        # @api public
        def total
          directory.base_total - 1
        end

      end
    end
  end
end
