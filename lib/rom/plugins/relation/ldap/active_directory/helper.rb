module ROM
  module Plugins
    module Relation
      module LDAP
        module ActiveDirectory
          # Microsoft Active Directory specific extension.
          #
          # @api public
          module Helper

            ACCOUNT_DISABLED               = 2.freeze
            ACCOUNT_TEMP_DUPLICATE         = 256.freeze
            ACCOUNT_NORMAL                 = 512.freeze

            DOMAIN_CONTROLLER              = 532480.freeze
            PREAUTH_NOT_REQUIRED           = 4194304.freeze # Kerberos Preauthentication Disabled
            ENCRYPTED_TEXT_PWD_ALLOWED     = 128.freeze

            GROUP_GLOBAL                   = 2.freeze
            GROUP_LOCAL                    = 4.freeze
            GROUP_UNIVERSAL                = 8.freeze
            GROUP_SECURITY_ENABLED         = 2147483648.freeze

            HOMEDIR_REQUIRED               = 8.freeze
            INTERDOMAIN_TRUST_ACCOUNT      = 2048.freeze
            LOCKOUT                        = 16.freeze
            MNS_LOGON_ACCOUNT              = 131072.freeze
            NOT_DELEGATED                  = 1048576.freeze
            PARTIAL_SECRETS_ACCOUNT        = 67108864.freeze

            PASSWORD_NOT_REQUIRED          = 32.freeze
            PASSWORD_CANT_CHANGE           = 64.freeze
            PASSWORD_DONT_EXPIRE           = 65536.freeze
            SMARTCARD_REQUIRED             = 262144.freeze # Smart Card Login Enforced
            PASSWORD_EXPIRED               = 8388608.freeze

            SCRIPT                         = 1.freeze
            SERVER_TRUST_ACCOUNT           = 8192.freeze
            TRUSTED_FOR_DELEGATION         = 524288.freeze
            TRUSTED_TO_AUTH_FOR_DELEGATION = 16777216.freeze
            USE_DES_KEY_ONLY               = 2097152.freeze
            WORKSTATION_TRUST_ACCOUNT      = 4096.freeze

            FLAG   = "systemFlags:#{ROM::LDAP::MATCHING_RULE_BIT_AND}:".freeze
            GROUP  = "groupType:#{ROM::LDAP::MATCHING_RULE_BIT_AND}:".freeze
            MEMBER = "memberOf:#{ROM::LDAP::MATCHING_RULE_IN_CHAIN}:".freeze
            OPTS   = "options:#{ROM::LDAP::MATCHING_RULE_BIT_AND}:".freeze
            UAC    = "userAccountControl:#{ROM::LDAP::MATCHING_RULE_BIT_AND}:".freeze


            #
            # Accounts
            #

            def ad_accounts_all
              equals('sAMAccountType' => 805306368)
            end

            def ad_accounts_disabled
              ad_accounts_all.equals(UAC => ACCOUNT_DISABLED)
            end

            def ad_accounts_enabled
              ad_accounts_all.unequals(UAC => ACCOUNT_DISABLED)
            end

            def ad_accounts_insecure
              ad_accounts_all.equals(UAC => PASSWORD_NOT_REQUIRED)
            end

            def ad_accounts_expired_password
              ad_accounts_all.equals(UAC => PASSWORD_EXPIRED)
            end

            def ad_accounts_permanent_password
              ad_accounts_all.equals(UAC => PASSWORD_DONT_EXPIRE)
            end

            def ad_accounts_control(oid)
              ad_accounts_all.equals(UAC => oid)
            end

            def ad_accounts_membership(groupdn)
              ad_accounts_all.equals(MEMBER => groupdn)
            end

            def ad_accounts_with_email
              ad_accounts_all.present(:mailnickname)
            end

            def ad_accounts_with_fax
              ad_accounts_all.equals(proxyaddresses: 'FAX:*')
            end

            def ad_accounts_hidden_email
              unequals(objectclass: 'publicFolder').equals(msexchhidefromaddresslists: 'TRUE')
            end



            #
            # Groups and Objects
            #

            def ad_groups_security
              equals(GROUP => GROUP_SECURITY_ENABLED)
              # equals(grouptype: GROUP_SECURITY_ENABLED)
            end

            def ad_groups_universal
              equals(GROUP => GROUP_UNIVERSAL)
            end

            def ad_groups_empty
              equals(objectclass: 'group').missing(:member)
            end

            def ad_catalog_global
              equals(objectcategory: 'nTDSDSA', OPTS => SCRIPT)
            end

            def ad_computers
              equals(objectcategory: 'computer')
            end

            def ad_controllers
              ad_computers.equals(UAC => SERVER_TRUST_ACCOUNT)
            end

            def ad_exchanges
              equals(objectclass: 'msExchExchangeServer').unequals(objectclass: 'msExchExchangeServerPolicy')
            end

            def ad_contacts
              equals(objectcategory: 'contact')
            end

            def ad_unrenamable_object
              equals(FLAG => 134217728)
            end

            def ad_undeletable_object
              equals(FLAG => -GROUP_SECURITY_ENABLED)
            end

          end
        end
      end
    end
  end
end

ROM.plugins do
  adapter :ldap do
    register :ad_helper, ROM::Plugins::Relation::LDAP::ActiveDirectory::Helper, type: :relation
  end
end
