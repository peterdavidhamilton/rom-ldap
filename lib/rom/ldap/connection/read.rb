using ::BER

require 'rom/ldap/filter/builder'

module ROM
  module LDAP
    module Read
      # Connection Search Operation
      #
      # @option :filter [String] Required but fallsback to class attribute 'default_filter' if nil.
      #
      # @option :base [String] Required but falls back to class attribute 'default_base' if nil.
      #
      # @option :size [Integer] Can be set by gateway options passed to directory.
      #
      # @option :time [Integer] Can be set by gateway options passed to directory.
      #
      # @option :scope [Integer] Defaults to 'subtree'.
      #
      # @option :deref [Integer] Defaults to 'never'.
      #
      # @option :attributes [Array<Symbol/String>] Restrict attributes returned.
      #
      # @option :sort [Boolean, Array<String>] WIP! - irrelevant inside rom-ldap.
      #
      # @option :unlimited [Boolean] Exceed the default 1_000 limit.
      #
      # @return [PDU]
      #
      # @yield [Array<BER::Struct>]
      #
      # @api public
      def search(
        filter:,
        base:,
        size: nil,
        time: nil,
        scope: SCOPE_SUBTREE,
        deref: DEREF_NEVER,
        attributes: EMPTY_ARRAY,
        attributes_only: false,
        return_referrals: false,
        sort: false, # %w[dn]
        unlimited: true
      )

        raise ArgumentError, 'invalid search scope'              unless SCOPES.include?(scope)
        raise ArgumentError, 'invalid alias dereferencing value' unless DEREF_ALL.include?(deref)

        filter = build_filter(filter || self.class.default_filter)
        base ||= self.class.default_base
        size = size.to_i
        time = time.to_i
        refs = return_referrals
        message_id = next_msgid
        ber_attrs = Array(attributes).map { |attr| attr.to_s.to_ber }
        ber_sort = encode_sort_controls(sort)
        rfc2696_cookie = [126, EMPTY_STRING]
        result_pdu = nil
        query_limit = (0..126).cover?(size) ? size : 0
        counter = 0

        loop do
          request = [
            base.to_ber,
            scope.to_ber_enumerated,
            deref.to_ber_enumerated,
            query_limit.to_ber,
            time.to_ber,
            attributes_only.to_ber,
            filter.to_ber,
            ber_attrs.to_ber_sequence
          ].to_ber_appsequence(pdu_lookup(:search_request))

          controls = []

          if unlimited
            controls <<
              [
                PAGED_RESULTS.to_ber,
                false.to_ber,
                rfc2696_cookie.map(&:to_ber).to_ber_sequence.to_s.to_ber
              ].to_ber_sequence
          end

          controls << ber_sort if ber_sort
          controls = controls.empty? ? nil : controls.to_ber_contextspecific(0)

          ldap_write(request, controls, message_id)

          result_pdu = nil
          controls   = EMPTY_ARRAY

          while pdu = queued_read(message_id)
            referrals = pdu.search_referrals || EMPTY_ARRAY

            case pdu.app_tag
            when pdu_lookup(:search_returned_data)

              counter += 1
              message = "#{self.class}##{__callee__} #{counter}: #{pdu.search_entry.dn}"
              logger.debug(message)

              yield pdu.search_entry if block_given?

            when pdu_lookup(:search_result_referral)
              yield(search_referrals: referrals) if refs && block_given?

            when pdu_lookup(:search_result)
              result_pdu = pdu
              controls   = pdu.result_controls
              yield(search_referrals: referrals) if refs && pdu.referral? && block_given?
              break

            else
              raise ResponseTypeInvalidError, "invalid response-type in search: #{pdu.app_tag}"
            end
          end

          # break if counter == size

          more_pages = false

          if result_pdu.success? && controls
            controls.each do |c|
              next unless c.oid == PAGED_RESULTS
              more_pages = false

              next unless c.value && !c.value.empty?
              cookie = c.value.read_ber[1]

              if cookie && !cookie.empty?
                rfc2696_cookie[1] = cookie
                more_pages = true
              end
            end
          end

          break unless more_pages
        end

        result_pdu
      ensure
        message_queue.delete(message_id)
      end

      private

      # Delegate to Filter::Builder#contruct
      #
      # api private
      def build_filter(filter)
        Filter::Builder.construct(filter) if filter.is_a?(String)
      end

      # FIXME: Sort controls sill relevant?
      #
      # @example
      #   just a string
      #     => ['cn']
      #
      #   attribute, matchingRule, direction (true / false)
      #     => [['cn', 'matchingRule', true]]
      #
      #   multiple strings or arrays
      #     => ['givenname', 'sn']
      #
      # @param definitions [Boolean, Array]
      #
      # @api private
      def encode_sort_controls(definitions)
        return definitions unless definitions

        values = definitions.map do |control|
          attribute, rule, direction = Array(control)

          attribute = String(attribute).to_ber
          rule      = String(rule).to_ber if rule
          direction = direction.to_ber    if direction
          control   = attribute, rule, direction

          control.to_ber_sequence
        end

        [
          SORT_REQUEST.to_ber,
          false.to_ber,
          values.to_ber_sequence.to_s.to_ber
        ].to_ber_sequence
      end
    end
  end
end
