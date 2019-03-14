RSpec.describe ROM::LDAP::Directory::ENV do

  let(:uri) { 'ldap://127.0.0.1:10389' }

  let(:config) { {} }

  subject(:env) { ->{ described_class.new(uri, config) } }

  # clear any variables set by the console
  before do
    ENV['LDAPURI'] = nil
    ENV['LDAPHOST'] = nil
    ENV['LDAPPORT'] = nil
  end


  context 'Incorrect URI protocol' do
    let(:uri) { 'ldapx://127.0.0.1:10389' }

    it { is_expected.to raise_error(Dry::Types::ConstraintError) }
  end



  context 'Missing URI' do
    let(:uri) { nil }

    it 'sets host to ip address' do
      expect(env.call.to_h[:host]).to eql('127.0.0.1')
    end

    it 'infers standard port 389' do
      expect(env.call.to_h[:port]).to eql(389)
    end
  end


  context 'LDAPS with IP' do
    let(:uri) { 'ldaps://127.0.0.1' }

    it { is_expected.not_to raise_error }

    it 'sets host to ip address' do
      expect(env.call.to_h[:host]).to eql('127.0.0.1')
    end

    it 'infers standard port 636' do
      expect(env.call.to_h[:port]).to eql(636)
    end

    it 'sets path to nil' do
      expect(env.call.to_h[:path]).to eql(nil)
    end
  end



  context 'LDAP with hostname' do
    let(:uri) { 'ldap://example.com' }

    it { is_expected.not_to raise_error }

    it 'sets host to hostname' do
      expect(env.call.to_h[:host]).to eql('example.com')
    end

    it 'infers standard port 389' do
      expect(env.call.to_h[:port]).to eql(389)
    end

    it 'sets path to nil' do
      expect(env.call.to_h[:path]).to eql(nil)
    end
  end



  context 'Unix socket path' do
    let(:uri) { 'ldap:///var/run/ldap.sock' }

    it { is_expected.not_to raise_error }

    it 'sets port to nil' do
      expect(env.call.to_h[:port]).to eql(nil)
    end

    it 'sets host to nil' do
      expect(env.call.to_h[:host]).to eql(nil)
    end

    it 'sets path to filepath' do
      expect(env.call.to_h[:path]).to eql('/var/run/ldap.sock')
    end
  end


end
