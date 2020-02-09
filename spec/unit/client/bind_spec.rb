RSpec.describe ROM::LDAP::Client, '#bind' do

  include_context 'vendor', 'apache_ds'

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

  subject(:result) { client.bind(username: username, password: password) }

  context 'with valid credentials' do
    let(:password) { 'secret' }

    it 'returns successful response' do
      expect(result).to be_an_instance_of(ROM::LDAP::PDU)
      expect(result.bind_result?).to be(true)
      expect(result.success?).to be(true)
      expect(result.message).to eql('Success')
    end
  end

  context 'with invalid credentials' do
    let(:password) { 'wrong' }

    it { expect { result }.to raise_error(ROM::LDAP::BindError, username) }
  end

end
