require 'dry/core/cache'

module ROM
  module LDAP
    class Directory

      module Operations
        def self.included(klass)
          klass.class_eval do
            extend Dry::Core::Cache
          end
        end

        # Use connection to communicate with server.
        # If :base is passed, it overwrites the default base keyword.
        #
        # @option :filter [String, Array] AST or LDAP string.
        #   Defaults to class attribute.
        #
        # @param options [Hash] @see Connection::SearchRequest
        #
        # @return [Array<Entry>] Formatted hash like objects.
        #
        # @api public
        #
        def query(filter: DEFAULT_FILTER, **options)
          set, counter = [], 0

          # TODO: pageable and search referrals
          params = {
            base: base,
            expression: to_expression(filter),
            **options
            # paged: pageable?

            # return_refs: true
            # https://tools.ietf.org/html/rfc4511#section-4.5.3
          }

          # pdu = client.search(params) do |search_referrals: |
          pdu = client.search(params) do |dn, attributes|
            counter += 1
            logger.debug("#{counter}: #{dn}") if ::ENV['DEBUG']

            set << entity = Entry.new(dn, attributes)
            yield(entity) if block_given?
          end

          debug(pdu)

          set
        end

        def debug(pdu)
          return unless ::ENV['DEBUG']

          logger.debug(pdu.advice) if pdu&.advice
          logger.debug(pdu.message) if pdu&.message
          logger.debug(pdu.info) if pdu&.failure?
        end

        # Return all attributes for a distinguished name.
        #
        # @param dn [String]
        #
        # @return [Array<Entry>]
        #
        # @api public
        def by_dn(dn)
          raise(DistinguishedNameError, 'DN is required') unless dn

          query(base: dn, max: 1, attributes: ALL_ATTRS)
        end

        #
        #
        # @option :filter [String]
        # @option :password [String]
        #
        # @return [TrueClass, FalseClass]
        #
        # @api public
        def bind_as(filter:, password:)
          if (entity = query(filter: filter, max: 1).first)
            password = password.call if password.respond_to?(:call)

            pdu = client.bind(username: entity.dn, password: password)
            pdu.success?
          else
            false
          end
        rescue BindError
          false
        end

        # Used by gateway[filter] to infer schema at boot.
        #   Limited to 1000 and cached.
        #
        # @param filter [String] dataset schema filter
        #
        # @return [Array<Entry>]
        #
        # @api public
        def query_attributes(filter)
          fetch_or_store(base, filter) do
            query(
              filter: filter,
              base: base,
              max: 1_000, # attribute sample size
              attributes_only: true
              # paged: false
            )
          end
        end

        # Count all entries under the search base.
        #
        # @return [Integer]
        #
        # @api public
        def base_total
          query(base: base, attributes: %w[objectClass], attributes_only: true).count
        end

        #
        # @param tuple [Hash] tuple using formatted attribute names.
        #
        # @return [Entry, FalseClass] created LDAP entry or false.
        #
        # @api public
        def add(tuple)
          dn    = tuple.delete(:dn)
          attrs = canonicalise(tuple)
          raise(DistinguishedNameError, 'DN is required') unless dn

          log(__callee__, dn)

          pdu = client.add(dn: dn, attrs: attrs)

          pdu.success? ? find(dn) : pdu.success?
        end

        # client#rename > client#password_modify > client#update
        #
        # @param dn [String] distinguished name.
        #
        # @param tuple [Hash] tuple using formatted attribute names.
        #
        # @return [Entry, FalseClass] updated LDAP entry or false.
        #
        # @api public
        def modify(dn, tuple)
          log(__callee__, dn)

          # entry = find(dn)

          new_dn = tuple.delete(:dn)
          attrs  = canonicalise(tuple)

          rdn_attr, rdn_val = get_rdn(dn).split('=')

          # 1. Move rename
          if new_dn
            new_rdn = get_rdn(new_dn)
            parent  = get_parent_dn(new_dn)

            new_rdn_attr, new_rdn_val = new_rdn.split('=')

            replace = rdn_attr.eql?(new_rdn_attr)

            pdu = client.rename(dn: dn, rdn: new_rdn, replace: replace, superior: parent)

            if pdu.success?
              dn, rdn_attr, rdn_val = new_dn, new_rdn_attr, new_rdn_val
            end
          end

          # 2. Change password
          if attrs.key?('userPassword')
            new_pwd = attrs.delete('userPassword')
            entry   = find(dn)
            old_pwd = entry['userPassword']

            pdu = client.password_modify(dn, old_pwd: old_pwd, new_pwd: new_pwd)
          end

          # 3. Edit attributes
          if !attrs.empty?

            # Adding to RDN values?
            if attrs.key?(rdn_attr) && !attrs.key?(rdn_val)
              attrs[rdn_attr] = Array(attrs[rdn_attr]).unshift(rdn_val)
            end

            pdu = client.update(dn: dn, ops: attrs.to_a)
          end

          pdu.success? ? find(dn) : pdu.success?
        end

        # Tuple(s) by dn
        #
        # @param dn [String] distinguished name
        #
        # @return [Array<Hash>,Hash]
        #
        # @raise [DistinguishedNameError] DN not found
        #
        def find(dn)
          entry = by_dn(dn)
          raise(DistinguishedNameError, 'DN not found') unless entry

          entry.one? ? entry.first : entry
        end

        #
        # @param dn [String] distinguished name.
        #
        # @return [Entry, FalseClass] deleted LDAP entry or false.
        #
        # @api public
        def delete(dn)
          log(__callee__, dn)
          entry = find(dn)

          pdu = if pruneable?
                  controls = [OID[:delete_tree]]
                  client.delete(dn: dn, controls: controls)
                else
                  client.delete(dn: dn)
                end

          pdu.success? ? entry : pdu.success?
        end

        private

        # RDN - relative distinguished name
        #
        # @return [String]
        #
        # @api private
        def get_rdn(dn)
          dn.split(',')[0]
        end

        # Parent DN
        #
        # @return [String]
        #
        # @api private
        def get_parent_dn(dn)
          dn.split(',')[1..-1].join(',')
        end

        # Log operation attempt
        #
        def log(method, dn)
          logger.debug("#{self.class}##{method} '#{dn}'")
        end

        # Rename the formatted keys of the incoming tuple to their original
        #   server-side format.
        #
        # @note Used by Directory#add and Directory#modify
        #
        # @param tuple [Hash]
        #
        # @example
        #   # => canonicalise(population_count: 0) => { 'populationCount' => 0 }
        #
        # @api private
        def canonicalise(tuple)
          Functions[:tuplify].call(tuple, key_map)
        end
      end

    end
  end
end
