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
          expr   = to_exp(filter)

          @result = connection.search(base: base, expression: expr, **options) do |entity|
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
          log(__callee__, to_ldap(filter))
        end

        # @option :filter [String]
        #
        # @option :password [String]
        #
        # @return [Boolean]
        #
        # @api public
        def bind_as(filter:, password:)
          if entity = query(filter: filter, max_results: 1).first
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

        # Count everything within the base, inclusive.
        #
        # @return [Integer]
        #
        # @api public
        def base_total
          query(base: base, attributes: %i[cn]).count
        end

        # @param tuple [Hash]
        #
        # @return [Boolean]
        #
        # @api public
        def add(tuple)
          payload = tuple_translation(tuple)

          args    = LDAP::Functions[:coerce_tuple_in][payload]
          dn      = args.delete(:dn)

          raise OperationError, 'distinguished name is required' if dn.nil?
          result = connection.add(dn: dn, attributes: args)
          log(__callee__, dn)
          result.success?
        end

        # @param dn [String]
        #
        # @param tuple [Hash]
        #
        # @return [Hash,Boolean]
        #
        # @api public
        def modify(dn, tuple)
          # raise OperationError, 'distinguished name is required' if dn.nil?
          payload    = tuple_translation(tuple)

          operations = payload.map { |attribute, value| [:replace, attribute, value] }

          connection.modify(dn: dn, operations: operations)

          result = connection.modify(dn: dn, operations: operations)

          log(__callee__, dn)

          result.success? ? find_by_dn(dn) : false
        end

        # Find an entry by its RDN.
        #
        # @param dn [String]
        #
        # @return [Entity]
        #
        def find_by_dn(dn)
          rdn = dn.split(',').first.split('=')
          query(filter: [:op_eql, *rdn], max_results: 1).first
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



        # conn.modify(args)

        # def add_attribute(dn, attribute, value)
        #   modify(:dn => dn, :operations => [[:add, attribute, value]])
        # end

        # def delete_tree(args)
        #    delete(args.merge(:control_codes => [[Net::LDAP::LDAPControls::DELETE_TREE, true]]))
        # end

        # def delete_attribute(dn, attribute)
        #   modify(:dn => dn, :operations => [[:delete, attribute, nil]])
        # end

        # def replace_attribute(dn, attribute, value)
        #   modify(:dn => dn, :operations => [[:replace, attribute, value]])
        # end



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
          LDAP::Functions[:rename_keys, trans][tuple.dup]
        end

        # Export a query as a nested Expression.
        # If the directory has loaded it passes the parsed directory attributes array
        # to the function in order to map canonical attribute names to their LDAP originals.
        #
        # @param filter [String]
        #
        # @return [Expression]
        #
        # @api private
        def to_exp(filter)
          Functions[:to_exp][filter]
        end

        def to_ldap(filter)
          Functions[:to_ldap][filter]
        end
      end
    end
  end
end