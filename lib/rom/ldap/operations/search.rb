using ::BER

require 'rom/ldap/dataset/filter/builder'

module ROM
  module LDAP
    module Search

      # @option base
      #
      # @option scope
      #
      # @option filter
      #
      # @option size
      #
      # @api public
      def search(
        filter:             self.class.default_filter,
        base:               directory_options[:base],
        # size:               directory_options[:size],
        # time:               directory_options[:timeout],
        size:               nil,
        time:               nil,
        scope:              SCOPE_SUBTREE,
        deref:              DEREF_NEVER,
        attributes:         EMPTY_ARRAY,
        attributes_only:    false,
        return_referrals:   false,
        sort_controls:      false,
        ignore_server_caps: false,
        paged:              true,
        message_id:         next_msgid
      )

        # otherwise resets limited to 1_000
        paged = false if ignore_server_caps

        raise ArgumentError, 'invalid search scope'              unless SCOPES.include?(scope)
        raise ArgumentError, 'invalid alias dereferencing value' unless DEREF_ALL.include?(deref)

        filter      = build_query(filter)
        base        ||= self.class.default_base
        size        = size.to_i
        time        = time.to_i
        refs        = return_referrals
        sort        = sort_controls
        ber_attrs   = Array(attributes).map { |attr| attr.to_s.to_ber }
        ber_sort    = encode_sort_controls(sort)

        rfc2696_cookie = [126, EMPTY_STRING]
        result_pdu     = nil                  # result object
        n_results      = 0                    # result counter

        loop do
          query_limit = 0

          if size > 0
            query_limit = if paged
                            ((size - n_results) < 126 ? (size - n_results) : 0)
                          else
                            size
                          end
          end

          request = [
            base.to_ber,
            scope.to_ber_enumerated,
            deref.to_ber_enumerated,
            query_limit.to_ber,
            time.to_ber,
            attributes_only.to_ber,
            filter.to_ber,
            ber_attrs.to_ber_sequence
          ].to_ber_appsequence(find_pdu(:search_request))

          controls = []

          if paged
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
            referrals  = pdu.search_referrals || EMPTY_ARRAY

            case pdu.app_tag
            when find_pdu(:search_returned_data)
              n_results += 1
              yield pdu.search_entry if block_given?

            when find_pdu(:search_result_referral)
              yield(search_referrals: referrals) if refs && block_given?

            when find_pdu(:search_result)
              result_pdu, controls = pdu, pdu.result_controls
              yield(search_referrals: referrals) if refs && pdu.referral? && block_given?
              break

            else
              raise ResponseTypeInvalidError, "invalid response-type in search: #{pdu.app_tag}"
            end
          end

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
        messages = message_queue.delete(message_id)
      end

      private

      def build_query(filter)
        Dataset::Filter::Builder.construct(filter) if filter.is_a?(String)
      end

      def encode_sort_controls(sort_definitions)
        return sort_definitions unless sort_definitions

        sort_control_values = sort_definitions.map do |control|
          control = Array(control)

          control[0] = String(control[0]).to_ber,
                       control[1] = String(control[1]).to_ber,
                       control[2] = (control[2] == true).to_ber

          control.to_ber_sequence
        end

        sort_control = [
          SORT_REQUEST.to_ber,
          false.to_ber,
          sort_control_values.to_ber_sequence.to_s.to_ber
        ].to_ber_sequence
      end
    end
  end
end
