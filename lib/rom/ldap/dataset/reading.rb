begin
  require 'yaml'
  require 'json'
  require 'msgpack'
rescue LoadError
end

using ::LDIF

module ROM
  module LDAP
    class Dataset
      module Reading

        # @see Connection::Read#encode_sort_controls
        #
        # Alphabetical increasing
        # Numerical increasing
        # FALSE to TRUE
        #
        # @param attribute [String,Symbol]
        #
        def order_by(attribute)
          with(sort_attr: [original_name(attribute)])
        end

        # @param attr [String, Symbol]
        # @return [String] server-side version of attribute
        # @note passed as 'sort' value to directory#search
        #
        def original_name(attr)
          directory.attribute_types.find { |a| a[:name].eql?(attr) }[:original]
        end

        # Find by Distinguished Name(s)
        #
        # @note This is not the same as Relation#fetch.
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

        # Handle different string output formats i.e. LDIF, JSON, YAML, MessagePack
        #
        # @example export(format: :to_yaml, keys: [:dn, :cn])
        #
        # @option :format [String] method to call
        # @option :keys [Array] schema keys to select
        #
        # @return [String] formatted output
        #
        # @api
        def export(format:, keys:)
          results = select(*keys).map(&:source)
          if results.size > 1
            results.__send__(format)
          else
            results.first.__send__(format)
          end
        end

        # Unrestricted count of every entry under the search base
        #   with the domain entry discounted.
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
