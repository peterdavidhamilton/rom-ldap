RSpec.describe ROM::LDAP::Client, '#bind' do

  include_context 'vendor', 'apache_ds'

  describe ':bind_result' do

    let(:username) { "cn=secure,#{base}" }

    before do
      directory.add(
        dn: username,
        cn: 'Strong',
        sn: 'Password',
        userPassword: 'secret',
        objectClass: 'person'
      )
    end

    after do
      directory.delete(username)
    end

    subject(:pdu) { client.bind(username: username, password: password) }

    context 'with valid credentials' do
      let(:password) { 'secret' }

      it { expect(pdu).to be_an_instance_of(ROM::LDAP::PDU) }
      it { expect(pdu.bind_result?).to be(true) }
      it { expect(pdu.success?).to be(true) }
      it { expect(pdu.message).to eql('Success') }
    end

    context 'with invalid credentials' do
      let(:password) { 'wrong' }

      it { expect(pdu).to be_an_instance_of(ROM::LDAP::PDU) }
      it { expect(pdu.bind_result?).to be(true) }
      it { expect(pdu.success?).to be(false) }
      it { expect(pdu.message).to eql('Invalid Credentials') }
    end
  end

end
