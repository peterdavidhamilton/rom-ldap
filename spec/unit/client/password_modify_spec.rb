RSpec.describe ROM::LDAP::Client, '#password_modify' do

  with_vendors do

    let(:dn) { "cn=Peter Hamilton,#{base}" }

    let(:old_clear_passwd) { 'initial' }
    let(:new_clear_passwd) { 'minimum of 5 characters' }

    before do
      directory.add(
        dn: dn,
        cn: 'Peter Hamilton',
        sn: 'Hamilton',
        object_class: 'person',
        user_password: old_clear_passwd
      )
    end


    let(:user) { directory.find(dn) }

    after { directory.delete(dn) }


    context 'as admin' do
      context 'when old password is not known' do
        it do
          case vendor
          when '389_ds'
            skip '389DS requires a secure connection for password changes'
          else
            old_encrypted_passwd = user[:user_password][0]

            result = client.password_modify(dn: dn, new_pwd: new_clear_passwd)

            new_encrypted_passwd = directory.by_dn(dn).first[:user_password][0]

            expect(new_encrypted_passwd).to_not eql(old_encrypted_passwd)

            expect(result).to be_an_instance_of(ROM::LDAP::PDU)
            expect(result.success?).to be(true)
          end
        end
      end

      context 'when old password is correct' do
        it do
          expect(user[:user_password]).to_not be_empty

          case vendor
          when 'open_ldap'
            expect(old_clear_passwd).to eq(user[:user_password][0])

          when '389_ds'
            skip '389DS requires a secure connection for password changes'

            old_encrypted_passwd = user[:user_password][0]

            old_pwd_valid = ROM::LDAP::Directory::Password.check_sha512(
                              old_clear_passwd,
                              old_encrypted_passwd
                            )

            expect(old_pwd_valid).to be(true)

          else
            old_encrypted_passwd = user[:user_password][0]

            old_pwd_valid = ROM::LDAP::Directory::Password.check_ssha(
                              old_clear_passwd,
                              old_encrypted_passwd
                            )

            expect(old_pwd_valid).to be(true)
          end


          result  = client.password_modify(
                      dn:      dn,
                      old_pwd: old_clear_passwd,
                      new_pwd: new_clear_passwd
                    )

          expect(result).to be_an_instance_of(ROM::LDAP::PDU)
          expect(result.success?).to be(true)

          new_encrypted_passwd = directory.by_dn(dn).first[:user_password][0]

          expect(new_encrypted_passwd).to_not eql(old_encrypted_passwd)

          new_pwd_valid = ROM::LDAP::Directory::Password.check_ssha(
                            new_clear_passwd,
                            new_encrypted_passwd
                          )

          expect(new_pwd_valid).to be(true)
        end
      end


      context 'when old password is wrong' do
        it do
          result  = client.password_modify(
                      dn:      dn,
                      old_pwd: 'wrong password',
                      new_pwd: new_clear_passwd
                    )

          expect(result).to be_an_instance_of(ROM::LDAP::PDU)
          expect(result.success?).to be(false)

          case vendor
          when 'open_ldap'
            expect(result.message).to eql('Unwilling To Perform')
            expect(result.info).to include('cannot process the request because of server-defined restrictions')
          when 'apache_ds'
            expect(result.message).to eql('No Such Attribute')
            expect(result.info).to include('attribute specified in the modify or compare operation does not exist in the entry')
          when 'open_dj'
            expect(result.message).to eql('Invalid Credentials')
            expect(result.info).to include('incorrect DN or password')
          when '389_ds'
            expect(result.message).to eql('Confidentiality Required')
            expect(result.info).to include('session is not protected by a protocol such as Transport Layer Security (TLS)')
          end
        end
      end

    end



    context 'when changing your own' do

      let(:own) do
        TestConfiguration.new(:ldap,
          uri_for(vendor),
          username: dn,
          password: old_clear_passwd
        ).gateways[:default].directory
      end

      it do
        if vendor == '389_ds'
          # the session is not protected by a protocol such as Transport Layer Security (TLS)
          skip '389DS requires a secure connection for password changes'
        end

        result  = own.client.password_modify(
                    dn:      dn,
                    old_pwd: old_clear_passwd,
                    new_pwd: new_clear_passwd
                  )
        expect(result).to be_an_instance_of(ROM::LDAP::PDU)
        expect(result.success?).to be(true)
      end
    end



    context "when changing someone else's password" do

      let(:other_dn) { "cn=Mysterio,#{base}" }

      before do
        directory.add(
          dn: other_dn,
          cn: 'Mysterio',
          sn: 'Beck',
          object_class: 'person',
          user_password: 'secret'
        )
      end

      after { directory.delete(other_dn) }

      let(:another) do
        TestConfiguration.new(:ldap,
          uri_for(vendor),
          username: other_dn,
          password: 'secret'
        ).gateways[:default].directory
      end

      it do
        old_known = another.client.password_modify(
                    dn:      dn,
                    old_pwd: old_clear_passwd,
                    new_pwd: new_clear_passwd
                  )

        case vendor
        when '389_ds'
          expect(old_known.info).to match(/session is not protected by a protocol such as Transport Layer Security/)
        when 'apache_ds', 'open_dj'
          expect(old_known.info).to match(/sufficient rights to perform the requested operation/)
        when 'open_ldap'
          expect(old_known.info).to match(/Connection restrictions prevent the action/)
          expect(old_known.info).to match(/Password restrictions prevent the action/)
        end

        expect(old_known).to be_an_instance_of(ROM::LDAP::PDU)
        expect(old_known.success?).to be(false)
      end

      it do
        old_unknown = another.client.password_modify(
                    dn:      dn,
                    new_pwd: new_clear_passwd
                  )

        case vendor
        when '389_ds'
          expect(old_unknown.info).to match(/session is not protected by a protocol such as Transport Layer Security/)
        when 'apache_ds', 'open_dj', 'open_ldap'
          expect(old_unknown.info).to match(/sufficient rights to perform the requested operation/)
        end

        expect(old_unknown).to be_an_instance_of(ROM::LDAP::PDU)
        expect(old_unknown.success?).to be(false)
      end
    end

  end
end
