require 'ber'
using ::BER

require 'rom/ldap/search_request'

module ROM
  module LDAP
    class Client
      # @abstract
      #   Adds entry creation capability to the connection.
      #
      module Operations
        #
        # @see https://tools.ietf.org/html/rfc4511#section-4.2
        # @see https://tools.ietf.org/html/rfc4513
        #
        # The Bind request is defined as follows:
        #
        #   BindRequest ::= [APPLICATION 0] SEQUENCE {
        #        version                 INTEGER (1 ..  127),
        #        name                    LDAPDN,
        #        authentication          AuthenticationChoice }
        #
        #   AuthenticationChoice ::= CHOICE {
        #        simple                  [0] OCTET STRING,
        #                                -- 1 and 2 reserved
        #        sasl                    [3] SaslCredentials,
        #        ...  }
        #
        #   SaslCredentials ::= SEQUENCE {
        #        mechanism               LDAPString,
        #        credentials             OCTET STRING OPTIONAL }
        #
        #
        # @option :username [String]
        #
        # @option :password [String]
        #
        # @option :version [Integer] Defaults to 3.
        #
        # @option :method [Symbol] Defaults to :simple.
        #
        # @return [PDU] result object
        #
        # @api public
        def bind(username:, password:, version: 3, method: :simple)
          request_type = pdu_lookup(:bind_request)

          request = [
            version.to_ber,
            username.to_ber,
            password.to_ber_contextspecific(0)
          ].to_ber_appsequence(request_type)

          submit(:bind_result, request)
        end

        # Connection Search Operation
        #
        # @see https://tools.ietf.org/html/rfc4511#section-4.5.3
        # @see https://tools.ietf.org/html/rfc2696
        #
        # @todo Write spec for yielding search_referrals
        #
        # @yield [Entry]
        # @yield [Hash] :search_referrals
        #
        # @api private
        def search(return_refs: true, **params)
          search_request = SearchRequest.new(params)
          request_type   = pdu_lookup(:search_request)
          result_pdu     = nil

          more_pages = false
          paged_results_cookie = [126, EMPTY_STRING]
          # paged_results_cookie = [10, EMPTY_STRING]

          request    = search_request.parts.to_ber_appsequence(request_type)
          controls   = search_request.controls
          message_id = next_msgid

          loop do
            write(request, controls, message_id)

            result_pdu = nil
            controls   = EMPTY_ARRAY

            while pdu = from_queue(message_id)
              case pdu.app_tag
              when pdu_lookup(:search_returned_data) # 4
                yield(pdu.search_entry)

              when pdu_lookup(:search_result) # 5
                result_pdu = pdu
                controls   = pdu.result_controls
                yield(search_referrals: pdu.search_referrals) if return_refs && pdu.search_referral?
                break

              when pdu_lookup(:search_result_referral) # 19
                yield(search_referrals: pdu.search_referrals) if return_refs

              else
                raise ResponseTypeInvalidError, "invalid response-type in search: #{pdu.app_tag}"
              end

            end



            if result_pdu&.success?
              controls.each do |c|

                next if c.oid != CONTROLS[:paged_results]

                next if c.value&.empty?

                # [ 0, "" ]
                _int, cookie = c.value.read_ber

                # next page of results
                #
                if !cookie&.empty?

                  # cookie => "\u0001\u0000\u0000"
                  # cookie.read_ber => true

                  paged_results_cookie[1] = cookie
                  more_pages = true
                end
              end
            end

            break unless more_pages
          end

          result_pdu
        ensure
          queue.delete(message_id)
        end

        #
        # @option :dn [String] distinguished name
        # @option :attrs [Array]
        #
        # @api private
        def add(dn:, attrs:)
          request_type = pdu_lookup(:add_request)

                ber_attrs = attrs.each_with_object([]) do |(k, v), attributes|
                  ber_values = Array(v).map { |v| v.to_ber }.to_ber_set
                  attributes << [k.to_s.to_ber, ber_values].to_ber_sequence
                end

          request = [
            dn.to_ber,
            ber_attrs.to_ber_sequence
          ].to_ber_appsequence(request_type)

          submit(:add_response, request)
        end

        # @option :dn [String] distinguished name
        #
        # @option :control_codes [?]
        #
        # @api private
        def delete(dn:, control_codes: nil)
          request_type = pdu_lookup(:delete_request)
          request = dn.to_ber_application_string(request_type)
          controls = control_codes.to_ber_control if control_codes

          submit(:delete_response, request, controls)
        end


        # @option :dn [String] distinguished name
        #
        # @option :ops [Array<Mixed>] operation ast
        #
        # @return [PDU] result object
        #
        # @api private
        def update(dn:, ops:)
          request_type = pdu_lookup(:modify_request)
          operations = modify_ops(ops)

          request = [
            dn.to_ber,
            operations.to_ber_sequence
          ].to_ber_appsequence(request_type)

          submit(:modify_response, request)
        end

        # TODO: spec rename and use by relations
        #
        # @option :dn [String] current distinguished name
        #
        # @option :rdn [String] new relative distinguished name
        #
        # @option :replace [TrueClass] replace existing rdn
        #
        # @option :superior [String] new parent dn
        #
        # @return [PDU] result object
        #
        # @api public
        def rename(dn:, rdn:, replace: false, superior: nil)
          request_type = pdu_lookup(:modify_rdn_request)

          request = [dn, rdn, replace].map { |a| a.to_ber }

          request << superior.to_ber_contextspecific(0) if superior

          request = request.to_ber_appsequence(request_type)

          submit(:modify_rdn_response, request)
        end

        # Password should have a minimum of 5 characters.
        #
        # @see http://tools.ietf.org/html/rfc3062
        #
        # @option :dn [String] distinguished name
        #
        # @option :old_pwd [String] current password
        #
        # @option :new_pwd [String] replacement password
        #
        # @return [PDU] result object
        #
        # @api public
        def password_modify(dn:, old_pwd:, new_pwd:)
          request_type = pdu_lookup(:extended_request)
          context = EXTENSIONS[:password_modify].to_ber_contextspecific(0)
          payload = [
                      dn.to_ber(0x80),              # 128
                      old_pwd.to_ber(0x81),         # 129
                      new_pwd.to_ber(0x82)          # 130
                    ].to_ber_sequence.to_ber(0x81)  # 129

          request = [context, payload].to_ber_appsequence(request_type)

          submit(:extended_response, request)
        end

        private

        #
        # Operation Tokens
        #
        # MODIFY_OPERATIONS = { add: 0, delete: 1, replace: 2 }.freeze

        # Encode operation AST to BER
        #
        # @param operations [Array]
        #
        # @return [Array] BER encoded operations
        #
        # @api private
        def modify_ops(operations = EMPTY_ARRAY)

# [
#     [0] [
#         [0] "cn",
#         [1] [
#             [0] "Hawkeye",
#             [1] "Goliath"
#         ]
#     ],
#     [1] [
#         [0] "givenName",
#         [1] "Clint"
#     ],
#     [2] [
#         [0] "sn",
#         [1] "Barton"
#     ]
# ]
          operations.each_with_object([]) do |(attribute, values), ops|
            payload = [
              attribute.to_s.to_ber,
              values_to_ber_set(values)
            ].to_ber_sequence

            ops << [
              2.to_ber_enumerated, # :replace
              payload
            ].to_ber
          end
          # operations.each_with_object([]) do |(op, attr, values), ops|
          #   op_ber = MODIFY_OPERATIONS[op].to_ber_enumerated
          #   values = [values].flat_map { |v| v&.to_ber }.to_ber_set
          #   values = [attr.to_s.to_ber, values].to_ber_sequence

          #   ops << [op_ber, values].to_ber
          # end
        end


        def values_to_ber_set(values)
          Array(values).map { |v| v&.to_ber }.to_ber_set
        end

                # ber_attrs = attrs.each_with_object([]) do |(k, v), attributes|
                #   ber_values = Array(v).map { |v| v.to_ber }.to_ber_set
                #   attributes << [k.to_s.to_ber, ber_values].to_ber_sequence
                # end


      end
    end
  end
end
