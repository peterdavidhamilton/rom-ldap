# frozen_string_literal: true

# rubocop:disable Layout/HashAlignment

module ROM
  module LDAP
    # LDAP OID hash map
    #
    # @see http://oid-info.com/get/{{OID}}
    # @see https://ldap.com/ldap-oid-reference-guide/
    # @see http://ldapwiki.com/wiki/LDAP%20Extensions%20and%20Controls%20Listing
    #
    # @return [Hash]
    #
    # @api private
    #
    OID = {
      matched_values:                   '1.2.826.0.1.3344810.2.3',
      paged_results:                    '1.2.840.113556.1.4.319',
      show_deleted:                     '1.2.840.113556.1.4.417',
      sort_request:                     '1.2.840.113556.1.4.473',
      sort_response:                    '1.2.840.113556.1.4.474',
      crossdom_move_target:             '1.2.840.113556.1.4.521',
      search_notification:              '1.2.840.113556.1.4.528',
      lazy_commit:                      '1.2.840.113556.1.4.619',
      sd_flags:                         '1.2.840.113556.1.4.801',
      matching_rule_bit_and:            '1.2.840.113556.1.4.803',
      matching_rule_bit_or:             '1.2.840.113556.1.4.804',
      delete_tree:                      '1.2.840.113556.1.4.805',
      directory_sync:                   '1.2.840.113556.1.4.841',
      verify_name:                      '1.2.840.113556.1.4.1338',
      domain_scope:                     '1.2.840.113556.1.4.1339',
      search_options:                   '1.2.840.113556.1.4.1340',
      permissive_modify:                '1.2.840.113556.1.4.1413',
      fast_concurrent_bind:             '1.2.840.113556.1.4.1781',
      matching_rule_in_chain:           '1.2.840.113556.1.4.1941',
      server_policy_hints:              '1.2.840.113556.1.4.2239',
      cancel_operation:                 '1.3.6.1.1.8',
      assertion:                        '1.3.6.1.1.12',
      pre_read:                         '1.3.6.1.1.13.1',
      post_read:                        '1.3.6.1.1.13.2',
      modify_increment:                 '1.3.6.1.1.14',
      transaction_start_request:        '1.3.6.1.1.21.1',
      transaction_spec_request:         '1.3.6.1.1.21.2',
      transaction_end_request:          '1.3.6.1.1.21.3',
      dont_use_copy:                    '1.3.6.1.1.22',
      password_policy_request:          '1.3.6.1.4.1.42.2.27.8.5.1',
      get_effective_rights_request:     '1.3.6.1.4.1.42.2.27.9.5.2',
      account_usable_request:           '1.3.6.1.4.1.42.2.27.9.5.8',
      apple_oid_prefix:                 '1.3.6.1.4.1.63',
      notice_of_disconnection:          '1.3.6.1.4.1.1466.20036',
      start_tls:                        '1.3.6.1.4.1.1466.20037',
      ns_transmitted:                   '1.3.6.1.4.1.1466.29539.12',
      dynamic_refresh:                  '1.3.6.1.4.1.1466.101.119.1',
      all_operational_attributes:       '1.3.6.1.4.1.4203.1.5.1',
      oc_ad_lists:                      '1.3.6.1.4.1.4203.1.5.2',
      true_false_filters:               '1.3.6.1.4.1.4203.1.5.3',
      language_tag_options:             '1.3.6.1.4.1.4203.1.5.4',
      language_range_options:           '1.3.6.1.4.1.4203.1.5.5',
      sync_request:                     '1.3.6.1.4.1.4203.1.9.1.1',
      sync_state:                       '1.3.6.1.4.1.4203.1.9.1.2',
      sync_done:                        '1.3.6.1.4.1.4203.1.9.1.3',
      sync_info_message:                '1.3.6.1.4.1.4203.1.9.1.4',
      subentries:                       '1.3.6.1.4.1.4203.1.10.1',
      password_modify:                  '1.3.6.1.4.1.4203.1.11.1',
      dereference:                      '1.3.6.1.4.1.4203.666.5.16',
      cascade:                          '1.3.6.1.4.1.18060.0.0.1',
      launch_diagnostic_ui_request:     '1.3.6.1.4.1.18060.0.1.1',
      launch_diagnostic_ui_response:    '1.3.6.1.4.1.18060.0.1.2',
      graceful_shutdown_request:        '1.3.6.1.4.1.18060.0.1.3',
      graceful_shutdown_response:       '1.3.6.1.4.1.18060.0.1.4',
      graceful_disconnect:              '1.3.6.1.4.1.18060.0.1.5',
      stored_procedure_request:         '1.3.6.1.4.1.18060.0.1.6',
      stored_procedure_response:        '1.3.6.1.4.1.18060.0.1.7',
      create_grouping_request:          '2.16.840.1.113719.1.27.103.1',
      create_grouping_response:         '2.16.840.1.113719.1.27.103.1',
      end_grouping_request:             '2.16.840.1.113719.1.27.103.2',
      end_grouping_response:            '2.16.840.1.113719.1.27.103.2',
      grouping:                         '2.16.840.1.113719.1.27.103.7',
      transaction_grouping:             '2.16.840.1.113719.1.27.103.8',
      manage_dsa_it:                    '2.16.840.1.113730.3.4.2',
      persistent_search:                '2.16.840.1.113730.3.4.3',
      netscape_password_expired:        '2.16.840.1.113730.3.4.4',
      netscape_password_expiring:       '2.16.840.1.113730.3.4.5',
      entry_change_notification:        '2.16.840.1.113730.3.4.7',
      virtual_list_view_request:        '2.16.840.1.113730.3.4.9',
      virtual_list_view_response:       '2.16.840.1.113730.3.4.10',
      proxied_authorization_v1:         '2.16.840.1.113730.3.4.12',
      replication_update_information:   '2.16.840.1.113730.3.4.13',
      search_on_specific_database:      '2.16.840.1.113730.3.4.14',
      authentication_response:          '2.16.840.1.113730.3.4.15',
      authentication_identity_request:  '2.16.840.1.113730.3.4.16',
      real_attribute_only_request:      '2.16.840.1.113730.3.4.17',
      proxied_authorization_v2:         '2.16.840.1.113730.3.4.18',
      virtual_attributes_only_request:  '2.16.840.1.113730.3.4.19'
    }.freeze
  end
end

# rubocop:enable Layout/HashAlignment
