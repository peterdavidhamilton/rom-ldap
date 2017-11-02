require 'net/ldap/entry'

module ROM
  module LDAP
    module Search

      INVALID_SEARCH = OpenStruct.new(
        status:      :failure,
        result_code: ResultCode::OperationsError,
        message:    'Invalid search'
      ).freeze



      SEARCH_REQUEST         = Net::LDAP::PDU::SearchRequest
      SEARCH_REQUEST         = Net::LDAP::PDU::SearchRequest
      SEARCH_RESULT          = Net::LDAP::PDU::SearchResult
      SEARCH_RESULT_REFERRAL = Net::LDAP::PDU::SearchResultReferral
      SEARCH_RETURNED_DATA   = Net::LDAP::PDU::SearchReturnedData



      def search(
        base: EMPTY_STRING,
        ignore_server_caps: nil,
        size: 10_000,
        filter: '(objectClass=*)',
        scope: SCOPE_SUBTREE,
        attributes: nil,
        attributes_only: false,
        return_referrals: false,
        deref: DEREF_NEVER,
        time: self.class.connect_timeout,
        paged_searches_supported: nil,
        sort_controls: false,
        message_id: next_msgid
      )

        attrs      = Array(attributes)
        attrs_only = attributes_only
        refs       = return_referrals

        size   = size.to_i
        time   = time.to_i
        paged  = paged_searches_supported
        sort   = sort_controls


        raise ArgumentError, 'invalid search scope'              unless SearchScopes.include?(scope)
        raise ArgumentError, 'invalid alias dereferencing value' unless DerefAliasesArray.include?(deref)


        filter    = LDAP::Dataset::FilterDSL.construct(filter) if filter.is_a?(String)

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
          ].to_ber_appsequence(SEARCH_REQUEST)

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
            when SEARCH_RETURNED_DATA
              n_results += 1
              yield pdu.search_entry if block_given?

            when SEARCH_RESULT_REFERRAL
              if refs
                if block_given?
                  # se = Net::LDAP::Entry.new
                  se = Hash.new
                  se[:search_referrals] = (pdu.search_referrals || EMPTY_ARRAY)
                  yield se
                end
              end

            when SEARCH_RESULT
              result_pdu = pdu
              controls = pdu.result_controls

              if refs && pdu.result_code == ResultCode::Referral # pdu.referral? predicate
                if block_given?
                  # se = Net::LDAP::Entry.new
                  se = Hash.new
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

          # if (result_pdu.result_code == ResultCode::Success) && controls
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
        end # loop

        result_pdu || INVALID_SEARCH
      ensure
        messages = message_queue.delete(message_id)
      end



      private

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
