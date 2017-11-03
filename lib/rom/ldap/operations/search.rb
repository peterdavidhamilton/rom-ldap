using ::BER

require 'rom/ldap/dataset/filter/builder'

module ROM
  module LDAP
    module Search
      # TODO: this is a mock PDU object - handle some other way
      INVALID_SEARCH = OpenStruct.new(
        status:      :failure,
        result_code: ResultCode['OperationsError'],
        message:    'Invalid search'
      ).freeze

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
        base:               EMPTY_STRING,
        scope:              SCOPE_SUBTREE,
        filter:             '(objectClass=*)',
        size:               10_000, # 126
        attributes:         nil,
        attributes_only:    false,
        return_referrals:   false,
        deref:              DEREF_NEVER,
        time:               self.class.connect_timeout,
        ignore_server_caps: nil,
        paged:              nil,
        sort_controls:      false,
        message_id:         next_msgid
      )

        attrs       = Array(attributes)
        attrs_only  = attributes_only
        refs        = return_referrals
        size        = size.to_i
        time        = time.to_i
        sort        = sort_controls

        raise ArgumentError, 'invalid search scope'              unless SearchScopes.include?(scope)
        raise ArgumentError, 'invalid alias dereferencing value' unless DerefAliasesArray.include?(deref)

        filter    = build_query(filter)
        ber_attrs = attrs.map { |attr| attr.to_s.to_ber }
        ber_sort  = encode_sort_controls(sort)

        rfc2696_cookie = [126, EMPTY_STRING]
        result_pdu     = nil
        n_results      = 0

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
            attrs_only.to_ber,
            filter.to_ber,
            ber_attrs.to_ber_sequence
          ].to_ber_appsequence(pdu(:search_request))

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
          controls   = []

          while pdu = queued_read(message_id)
            case pdu.app_tag
            when pdu(:search_returned_data)
              n_results += 1
              yield pdu.search_entry if block_given?

            when pdu(:search_result_referral)
              if refs
                if block_given?
                  se = {}
                  se[:search_referrals] = (pdu.search_referrals || EMPTY_ARRAY)
                  yield se
                end
              end

            when pdu(:search_result)
              result_pdu = pdu
              controls   = pdu.result_controls

              if refs && pdu.result_code == ResultCode['Referral'] # pdu.referral? predicate
                if block_given?
                  se = {}
                  se[:search_referrals] = (pdu.search_referrals || EMPTY_ARRAY)
                  yield se
                end
              end
              break
            else
              raise ResponseTypeInvalidError, "invalid response-type in search: #{pdu.app_tag}"
            end
          end # while

          more_pages = false

          if (result_pdu.result_code == ResultCode['Success']) && controls
            # if result_pdu.success? && controls

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
        end # loop

        result_pdu || INVALID_SEARCH
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
