# frozen_string_literal: true

module ROM
  module Plugins
    module Relation
      module LDAP
        # Microsoft Active Directory specific extension.
        #
        # @api public
        module ActiveDirectory
          ACCOUNT_DISABLED               = 2
          ACCOUNT_TEMP_DUPLICATE         = 256
          ACCOUNT_NORMAL                 = 512

          DOMAIN_CONTROLLER              = 532_480
          PREAUTH_NOT_REQUIRED           = 4_194_304 # Kerberos Preauthentication Disabled
          ENCRYPTED_TEXT_PWD_ALLOWED     = 128

          GROUP_GLOBAL                   = 2
          GROUP_LOCAL                    = 4
          GROUP_UNIVERSAL                = 8
          GROUP_SECURITY_ENABLED         = 2_147_483_648

          HOMEDIR_REQUIRED               = 8
          INTERDOMAIN_TRUST_ACCOUNT      = 2048
          LOCKOUT                        = 16
          MNS_LOGON_ACCOUNT              = 131_072
          NOT_DELEGATED                  = 1_048_576
          PARTIAL_SECRETS_ACCOUNT        = 67_108_864

          PASSWORD_NOT_REQUIRED          = 32
          PASSWORD_CANT_CHANGE           = 64
          PASSWORD_DONT_EXPIRE           = 65_536
          SMARTCARD_REQUIRED             = 262_144 # Smart Card Login Enforced
          PASSWORD_EXPIRED               = 8_388_608

          SCRIPT                         = 1
          SERVER_TRUST_ACCOUNT           = 8192
          TRUSTED_FOR_DELEGATION         = 524_288
          TRUSTED_TO_AUTH_FOR_DELEGATION = 16_777_216
          USE_DES_KEY_ONLY               = 2_097_152
          WORKSTATION_TRUST_ACCOUNT      = 4096

          RULE_BIT = ROM::LDAP::OID[:matching_rule_bit_and]
          RULE_CHAIN = ROM::LDAP::OID[:matching_rule_in_chain]

          FLAG   = "systemFlags:#{RULE_BIT}:"
          GROUP  = "groupType:#{RULE_BIT}:"
          MEMBER = "memberOf:#{RULE_CHAIN}:"
          OPTS   = "options:#{RULE_BIT}:"
          UAC    = "userAccountControl:#{RULE_BIT}:"

          #
          # Ambiguous Name Resolution (ANR)
          #
          # @return [Relation]
          #
          # @api public
          def ambiguous(value)
            equal('anr' => value)
          end

          # All DC's and their versions
          # '(&(&(&(&(samAccountType=805306369)(primaryGroupId=516))(objectCategory=computer)(operatingSystem=*))))'

          #
          # Accounts
          #

          # @return [Relation]
          #
          # @api public
          def ad_accounts_all
            equal('sAMAccountType' => 805_306_368)
          end

          # AD_USER_DISABLED = Filter::Builder.ex("userAccountControl:1.2.840.113556.1.4.803", "2")
          #
          # @return [Relation]
          #
          # @api public
          def ad_accounts_disabled
            ad_accounts_all.equal(UAC => ACCOUNT_DISABLED)
          end

          def ad_accounts_enabled
            ad_accounts_all.unequal(UAC => ACCOUNT_DISABLED)
          end

          def ad_accounts_insecure
            ad_accounts_all.equal(UAC => PASSWORD_NOT_REQUIRED)
          end

          def ad_accounts_expired_password
            ad_accounts_all.equal(UAC => PASSWORD_EXPIRED)
          end

          def ad_accounts_permanent_password
            ad_accounts_all.equal(UAC => PASSWORD_DONT_EXPIRE)
          end

          def ad_accounts_control(oid)
            ad_accounts_all.equal(UAC => oid)
          end

          def ad_accounts_membership(groupdn)
            ad_accounts_all.equal(MEMBER => groupdn)
          end

          def ad_accounts_with_email
            ad_accounts_all.present(:mailnickname)
          end

          # FIXME: the attribute names should be original format?
          # see for example ad_accounts_all
          #
          def ad_accounts_with_fax
            ad_accounts_all.equal(proxyaddresses: 'FAX:*')
          end

          def ad_accounts_hidden_email
            unequal(objectclass: 'publicFolder').equal(msexchhidefromaddresslists: 'TRUE')
          end

          #
          # Groups and Objects
          #

          # @return [Relation]
          #
          # @api public
          def ad_groups_security
            equal(GROUP => GROUP_SECURITY_ENABLED)
            # equal(grouptype: GROUP_SECURITY_ENABLED)
          end

          def ad_groups_universal
            equal(GROUP => GROUP_UNIVERSAL)
          end

          def ad_groups_empty
            equal(objectclass: 'group').missing(:member)
          end

          def ad_catalog_global
            equal(objectcategory: 'nTDSDSA', OPTS => SCRIPT)
          end

          def ad_computers
            equal(objectcategory: 'computer')
          end

          def ad_controllers
            ad_computers.equal(UAC => SERVER_TRUST_ACCOUNT)
          end

          def ad_exchanges
            equal(objectclass: 'msExchExchangeServer').unequal(objectclass: 'msExchExchangeServerPolicy')
          end

          def ad_contacts
            equal(objectcategory: 'contact')
          end

          def ad_unrenamable_object
            equal(FLAG => 134_217_728)
          end

          def ad_undeletable_object
            equal(FLAG => -GROUP_SECURITY_ENABLED)
          end
        end
      end
    end
  end
end

ROM.plugins do
  adapter :ldap do
    register :active_directory, ROM::Plugins::Relation::LDAP::ActiveDirectory, type: :relation
  end
end
