require 'rom/ldap/filter/transformer'

module ROM
  module LDAP
    class Directory
      module Operations
        #
        # @param options [Hash]
        #
        # @return [Array<Hash>]
        #
        # @api public
        def query(options)
          set  = []

          base       ||= self.class.default_base
          filters    = options.delete(:filter) || self.class.default_filter
          expression = merge_criteria(filters)

          @result = connection.search(base: base, expression: expression, **options) do |entity|
            set << entity
            yield entity if block_given?
          end

          set.sort_by(&:dn)
        end

        attr_reader :result # PDU object

        # Query results as array of hashes ordered by Distinguished Name
        #
        # @param filter [String]
        #
        # @return [Array<Hash>]
        #
        # @api public
        def search(filter, base: nil, &block)
          Timeout.timeout(timeout) do

            results = query(filter: filter,
                            base: base,
                            max_results: max_results,
                            deref: DEREF_ALWAYS,
                            unlimited: unlimited?)

            block_given? ? results.each(&block) : results
          end
        rescue Timeout::Error
          log(__callee__, "timed out after #{timeout} seconds", :warn)
        ensure
          log(__callee__, filter)
        end

        # @option :filter [String]
        #
        # @option :password [String]
        #
        # @option :version [Integer] defaults to server value or class attribute
        #
        # @return [Boolean]
        #
        # @api public
        def bind_as(filter:, password:, version: vendor_version)
          connection.bind_as(
            filter: filter,
            password: password,
            version: (version || self.class.ldap_version)
          )
        end

        # Used by gateway[filter] to infer schema. Limited to 100.
        #
        # @return [Integer]
        #
        # @api public
        def attributes(filter)
          query(filter: filter, max_results: 100, attributes_only: true, unlimited: false)
        end

        # Should count actual total
        #
        # @return [Integer]
        #
        # @api public
        def total(filter)
          query(filter: filter, attributes: %i[dn]).count
        end

        # @param tuple [Hash]
        #
        # @return [Boolean]
        #
        # @api public
        def add(tuple)
          trans   = tuple_translation(tuple)
          payload = LDAP::Functions[:rename_keys, trans][tuple.dup]
          args    = LDAP::Functions[:coerce_tuple_in][payload]
          dn      = args.delete(:dn)

          raise OperationError, 'distinguished name is required' if dn.nil?
          result = connection.add(dn: dn, attributes: args)
          log(__callee__, dn)
          result.success?
        end

        #
        # @return [Boolean]
        #
        # @api public
        def modify(dn, operations)
          raise OperationError, 'distinguished name is required' if dn.nil?
          result = connection.modify(dn: dn, operations: operations)
          log(__callee__, dn)
          result.success?
        end

        #
        # @param dn [String]
        #
        # @return [Boolean]
        #
        # @api public
        def delete(dn)
          raise OperationError, 'distinguished name is required' if dn.nil?
          result = connection.delete(dn: dn)
          log(__callee__, dn)
          result.success?
        end



        private

        # Is the server capable of paging and has a user defined limit not been set.
        #
        def unlimited?
          pageable? && max_results.nil?
        end

        # map from :uid_number => 'uidNumber'
        #
        def tuple_translation(tuple)
          attributes = attribute_types.select { |a| tuple.keys.include?(a[:name]) }
          attributes.map { |a| a.values_at(:name, :original) }.to_h
        end

        # merge orignal table name with criteria
        #
        def merge_criteria(filters)
          Array(filters).map(&method(:build_expression)).reduce(:&)
        end

        # whether a string or an ast the transformer returns an expression object
        #
        def build_expression(filter)
          Filter::Transformer.new(filter).to_exp
        end

      end
    end
  end
end
