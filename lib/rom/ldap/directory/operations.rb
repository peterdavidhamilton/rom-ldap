module ROM
  module LDAP
    class Directory
      module Operations
        #
        # @param options [Hash]
        #
        # @return [Array<Entity>]
        #
        # @api public
        def query(options)
          set  = []
          base ||= self.class.default_base
          filter = options.delete(:filter) || self.class.default_filter
          expr   = Functions[:to_exp][filter]

          @result = connection.search(base: base, expression: expr, **options) do |entity|
            set << entity
            yield entity if block_given?
          end

          set.sort_by(&:dn)
        end

        # Find an entry by its RDN.
        #
        # @param dn [String]
        #
        # @return [Entity]
        #
        def by_dn(dn)
          query(base: dn, max_results: 1)
        end

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
          log(__callee__, Functions[:to_ldap][filter])
        end

        # @option :filter [String]
        #
        # @option :password [String]
        #
        # @return [Boolean]
        #
        # @api public
        def bind_as(filter:, password:)
          if (entity = query(filter: filter, max_results: 1).first)
            password = password.call if password.respond_to?(:call)
            connection.bind(username: entity.dn, password: password)
          else
            false
          end
        end

        # Used by gateway[filter] to infer schema. Limited to 100.
        #
        # @return [Integer]
        #
        # @api public
        def attributes(filter)
          query(filter: filter, max_results: 100, attributes_only: true, unlimited: false)
        end

        # Count everything within the current base, inclusive of base entry.
        #
        # @return [Integer]
        #
        # @api public
        def base_total
          query(base: base, attributes: %i[cn]).count
        end

        # @param tuple [Hash] tuple using formatted attribute names.
        #
        # @return [Entity, Boolean] created LDAP entry or false.
        #
        # @example - must include valid dn
        #
        # @api public
        def add(tuple)
          payload = tuple_translation(tuple)

          args    = Functions[:coerce_tuple_in][payload]
          dn      = args.delete(:dn)

          raise OperationError, 'distinguished name is required' if dn.nil?
          result = connection.add(dn: dn, attrs: args)
          log(__callee__, dn)

          result.success? ? by_dn(dn).first : false
        end

        # @param dn [String] distinguished name.
        #
        # @param tuple [Hash] tuple using formatted attribute names.
        #
        # @return [Entity, Boolean] updated LDAP entry or false.
        #
        # @api public
        def modify(dn, tuple)
          payload    = tuple_translation(tuple)
          operations = payload.map { |attribute, value| [:replace, attribute, value] }
          result     = connection.modify(dn: dn, ops: operations)
          log(__callee__, dn)

          result.success? ? by_dn(dn).first : false
        end

        #
        # @param dn [String]
        #
        # @return [Boolean]
        #
        # @api public
        def delete(dn)
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

        # Build transaltion hash
        #
        # @return [Hash] { :uid_number => 'uidNumber' }
        #
        # TODO: move tuple_translation to a function and chain them
        # OPTIMIZE: Functions[:to_tuple][tuple, attribute_types]
        #
        # @api private
        def tuple_translation(tuple)
          attributes = attribute_types.select { |a| tuple.keys.include?(a[:name]) }
          trans = attributes.map { |a| a.values_at(:name, :original) }.to_h
          Functions[:rename_keys, trans][tuple.dup]
        end

      end
    end
  end
end
