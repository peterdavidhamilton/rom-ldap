#
# Entry.use_formatter(proc) defines the proc that
# will rename an entity's attributes name
#
RSpec.describe ROM::LDAP::Directory::Entry do
  describe 'Entry.formatter' do

    subject(:entity) { ROM::LDAP::Directory::Entry }

    describe 'when nil' do
      let(:formatter) { nil }
      include_context 'relations'

      it 'Entry.rename works' do
        expect(entity.rename('=HELLO World')).to eql('=HELLO World')
      end

      it 'uses the actual attribute name like "gidNumber" or "apple-imhandle"' do
        keys = %w[
          apple-imhandle
          cn
          createTimestamp
          creatorsName
          dn
          entryCSN
          entryDN
          entryParentId
          entryUUID
          gidNumber
          givenName
          mail
          nbChildren
          nbSubordinates
          objectClass
          pwdHistory
          sn
          subschemaSubentry
          uid
          uidNumber
          userPassword
        ]
        expect(accounts.schema.to_h.keys).to include(*keys)
      end
    end

    describe 'when mimicking Net::LDAP' do
      let(:formatter) { downcase_proc }
      include_context 'relations'

      it 'Entry.rename works' do
        expect(entity.rename('=HELLO World')).to eql(:helloworld)
      end

      it 'produces lowercase symbol attribute names like :gidnumber' do
        keys = %i[
          appleimhandle
          cn
          createtimestamp
          creatorsname
          dn
          entrycsn
          entrydn
          entryparentid
          entryuuid
          gidnumber
          givenname
          mail
          nbchildren
          nbsubordinates
          objectclass
          pwdhistory
          sn
          subschemasubentry
          uid
          uidnumber
          userpassword
        ]
        expect(accounts.schema.to_h.keys).to include(*keys)
      end
    end

    describe 'when using the default rom-ldap formatter' do
      let(:formatter) { method_name_proc }
      include_context 'relations'

      it 'Entry.rename works' do
        expect(entity.rename('=HELLO World')).to eql(:hello_world)
      end

      it 'produces snake_case symbol attribute names like :gid_number' do
           keys = %i[
            apple_imhandle
            cn
            create_timestamp
            creators_name
            dn
            entry_csn
            entry_dn
            entry_parent_id
            entry_uuid
            gid_number
            given_name
            mail
            nb_children
            nb_subordinates
            object_class
            pwd_history
            sn
            subschema_subentry
            uid
            uid_number
            user_password
          ]
        expect(accounts.schema.to_h.keys).to include(*keys)
      end
    end

    describe 'when using a "reverse formatter"' do
      let(:formatter) { reverse_proc }
      include_context 'relations'

      it 'Entry.rename works' do
        expect(entity.rename('=HELLO World')).to eql(:dlrowolleh)
      end

      it 'produces names like :rebmundig' do
        keys = %i[
            ditnerapyrtne
            diu
            diuuyrtne
            drowssapresu
            eldnahmielppa
            emannevig
            emansrotaerc
            liam
            nc
            nd
            ndyrtne
            nerdlihcbn
            ns
            nscyrtne
            pmatsemitetaerc
            rebmundig
            rebmundiu
            setanidrobusbn
            ssalctcejbo
            yrotsihdwp
            yrtnebusamehcsbus
          ]
        expect(accounts.schema.to_h.keys).to include(*keys)
      end
    end
  end
end
