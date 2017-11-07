module ROM
  module LDAP
    class Directory
      module Operations

        # @param options [Hash]
        #
        # @return [Array<Hash>]
        #
        # @api public
        def query(options, &block)
          result_set = []
          return_set = !options.delete(:result_only)

          @result = connection.search(base: base, **options) do |entry|
            result_set << entry
            yield entry if block_given?
          end

          return_set ? result_set.sort_by(&:dn) : !result_set.empty?
        end

        attr_reader :result # PDU object


        # Query results as array of hashes ordered by Distinguishing Name
        #
        # @param filter [String]
        #
        # @param scope
        #
        # @return [Array<Hash>]
        #
        # @api public
        def search(filter, &block)
          results = EMPTY_ARRAY

          # FIXME: size not currently enforced
          Timeout.timeout(timeout) do
            results = query(filter: filter, size: size, deref: DEREF_ALWAYS, unlimited: pageable?)
            block_given? ? results.each(&block) : results
          end

          rescue Timeout::Error
            log(__callee__, "timed out after #{timeout} seconds", :warn)
          ensure
            log(__callee__, filter)
            results
        end


        # @param args [Hash]
        #
        # @return
        #
        # @api public
        def bind_as(filter:, password:)
          connection.bind_as(filter: filter, password: password)
        end


        # Used by gateway[filter]
        #
        # @return [Integer]
        #
        # @api public
        def attributes(filter)
          query(filter: filter, size: 100, attributes_only: true, unlimited: false)
        end

        # Should count actual total
        #
        # @return [Integer]
        #
        # @api public
        def count(filter)
          query(filter: filter, attributes: %i[dn]).count
        end


        # @return [Boolean]
        #
        # @api public
        def exist?(filter)
          query(filter: filter, result_only: true)
        end


        # @param tuple [Hash]
        #
        # @return [Boolean]
        #
        # @api public
        def add(tuple)
          args = LDAP::Functions[:ldap_compatible][tuple.dup]
          dn   = args.delete(:dn)

          # raise OperationError, 'distinguished name is required' if dn.nil?

          result = connection.add(dn: dn, attributes: args)

          log(__callee__, dn)

          result.success?
        end


        #
        # @return [Boolean]
        #
        # @api public
        def modify(dn, operations)
          # raise OperationError, 'distinguished name is required' if dn.nil?

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
          # raise OperationError, 'distinguished name is required' if dn.nil?

          result = connection.delete(dn: dn)

          log(__callee__, dn)

          result.success?
        end

      end
    end
  end
end
