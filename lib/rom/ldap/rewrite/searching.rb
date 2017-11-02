require 'net/ldap/entry'
require 'net/ldap/filter'

module Searching

  INVALID_SEARCH = OpenStruct.new(
    status:      :failure,
    result_code: ROM::LDAP::ResultCode::OperationsError,
    message:    'Invalid search'
  ).freeze


  def search(
    base:,
    size:,
    filter: Net::LDAP::Filter.eq('objectClass', '*'),
    scope: SCOPE_SUBTREE,
    attributes: nil,
    attributes_only: false,
    return_referrals: false,
    deref: DEREF_NEVER,
    time: nil,
    paged_searches_supported: nil,
    sort_controls: false
  )

    attrs      = Array(attributes)
    attrs_only = attributes_only
    refs       = return_referrals

    size   = size.to_i
    time   = time.to_i
    paged  = paged_searches_supported
    sort   = sort_controls

    # raise ArgumentError, "search base is required" unless base
    # raise ArgumentError, "invalid search-size" unless size >= 0
    # raise ArgumentError, "invalid search scope" unless Net::LDAP::SearchScopes.include?(scope)
    # raise ArgumentError, "invalid alias dereferencing value" unless Net::LDAP::DerefAliasesArray.include?(deref)

    filter    = Net::LDAP::Filter.construct(filter) if filter.is_a?(String)
    ber_attrs = attrs.map { |attr| attr.to_s.to_ber }
    ber_sort  = encode_sort_controls(sort)

    rfc2696_cookie = [126, EMPTY_STRING]
    result_pdu     = nil
    n_results      = 0

    message_id = next_msgid

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
        query_limit.to_ber, # size limit
        time.to_ber,
        attrs_only.to_ber,
        filter.to_ber,
        ber_attrs.to_ber_sequence
      ].to_ber_appsequence(Net::LDAP::PDU::SearchRequest)

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

      write(request, controls, message_id)

      result_pdu = nil
      controls   = []

      while pdu = queued_read(message_id)
        case pdu.app_tag
        when Net::LDAP::PDU::SearchReturnedData
          n_results += 1
          yield pdu.search_entry if block_given?
        when Net::LDAP::PDU::SearchResultReferral
          if refs
            if block_given?
              se = Net::LDAP::Entry.new
              se[:search_referrals] = (pdu.search_referrals || [])
              yield se
            end
          end
        when Net::LDAP::PDU::SearchResult
          result_pdu = pdu
          controls = pdu.result_controls
          if refs && pdu.result_code == LDAP::ResultCode::Referral
            if block_given?
              se = Net::LDAP::Entry.new
              se[:search_referrals] = (pdu.search_referrals || [])
              yield se
            end
          end
          break
        else
          raise Net::LDAP::ResponseTypeInvalidError, "invalid response-type in search: #{pdu.app_tag}"
        end
      end

      more_pages = false

      if (result_pdu.result_code == LDAP::ResultCode::Success) && controls
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

end
