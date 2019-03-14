RSpec.describe ROM::LDAP::Client, '#password_modify' do

  include_context 'directory'

  let(:dn) { "cn=Peter Hamilton,#{base}" }

  let(:old_clear_passwd) { 'initial' }
  let(:new_clear_passwd) { 'minimum of 5 characters' }

  let(:user) do
    directory.add(
      dn: dn,
      cn: 'Peter Hamilton',
      sn: 'Hamilton',
      object_class: 'person',
      user_password: old_clear_passwd
    )
  end

  after { directory.delete(dn) }


  context 'when valid' do
    it 'changes userPassword' do
      old_encrypted_passwd = user[:user_password][0]

      old_pwd_valid = ROM::LDAP::Directory::Password.check_ssha(
                        old_clear_passwd,
                        old_encrypted_passwd
                      )

      expect(old_pwd_valid).to be(true)

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


  context 'when invalid' do

    # message changes when client is bound
    let(:bind_dn) { nil }

    it 'does not change userPassword' do
      expect(user.dn).to eql(dn)

      result  = client.password_modify(
                  dn:      dn,
                  old_pwd: 'wrong password',
                  new_pwd: new_clear_passwd
                )

      expect(result).to be_an_instance_of(ROM::LDAP::PDU)
      expect(result.success?).to be(false)
      expect(result.info).to include('incorrect DN or password')
      expect(result.message).to eql('Invalid Credentials')
    end
  end

end
