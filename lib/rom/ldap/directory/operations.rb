module ROM
  module LDAP
    class Directory
      module Operations
        # Find an entry by distinguished name.
        #
        # @param dn [String]
        #
        # @return [Entry]
        #
        def by_dn(dn)
          query(base: dn, max_results: 1)
        end

        # Query results as array of hashes ordered by Distinguished Name
        #
        # @param ast [Array]
        #
        # @option :base [String]
        #
        # @return [Array<Directory::Entry>]
        #
        # @api public
        def search(ast, base: nil, &block)
          Timeout.timeout(timeout) do
            results = query(filter: ast,
                            base: base,
                            max_results: max_results,
                            deref: DEREF_ALWAYS,
                            unlimited: unlimited?)

            block_given? ? results.each(&block) : results
          end
        rescue Timeout::Error
          log(__callee__, "timed out after #{timeout} seconds", :warn)
        ensure
          log(__callee__, Functions[:to_ldap][ast])
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
        # @return [Array<Directory::Entry>]
        #
        # @api public
        def attributes(filter)
          query(
            filter: filter,
            base: base,
            max_results: 100,
            attributes_only: true,
            unlimited: false
          )
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
        # @return [Entry, Boolean] created LDAP entry or false.
        #
        # @example - must include valid dn
        #
        # @api public
        def add(tuple)
          args = payload(tuple)
          dn   = args.delete(:dn)

          raise OperationError, 'distinguished name is required' if dn.nil?
          result = connection.add(dn: dn, attrs: args)
          log(__callee__, dn)

          result.success? ? by_dn(dn).first : false
        end

        # @param dn [String] distinguished name.
        #
        # @param tuple [Hash] tuple using formatted attribute names.
        #
        # @return [Entry, Boolean] updated LDAP entry or false.
        #
        # @api public
        def modify(dn, tuple) # third param :replace
          args   = payload(tuple)
          # TODO: MODIFY_OPERATIONS :add, :delete, :replace - handle adding another cn
          ops    = args.map { |attribute, value| [:replace, attribute, value] }
          result = connection.modify(dn: dn, ops: ops)

          log(__callee__, dn)
          result.success? ? by_dn(dn).first : false
        end
        # def replace_attribute
        # end
        # def add_attribute
        # end
        # def delete_attribute
        # end


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

        # Use connection to communicate with server.
        #
        # @param options [Hash]
        #
        # @return [Array<Entry>]
        #
        # @api private
        def query(options)
          set    = []
          filter = options.delete(:filter) || self.class.default_filter
          expr   = Functions[:to_exp][filter]

          @result = connection.search(base: base, expression: expr, **options) do |entity|
            set << entity
            yield entity if block_given?
          end

          set.sort_by(&:dn)
        end

        # Is the server capable of paging and has a user defined limit not been set.
        #
        def unlimited?
          pageable? && max_results.nil?
        end

        # Tuplify operation input, using a translation hash to rename keys.
        #
        # @api private
        def payload(tuple)
          attributes  = attribute_types.select { |a| tuple.keys.include?(a[:name]) }
          transmatrix = attributes.map { |a| a.values_at(:name, :original) }.to_h

          Functions[:tuplify].call(tuple.dup, transmatrix)
        end
      end
    end
  end
end
