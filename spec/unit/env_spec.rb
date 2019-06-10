RSpec.describe ROM::LDAP::Directory::ENV do

  before do
    @ldapuri  = ENV['LDAPURI']
    ENV['LDAPURI']  = nil

    @ldaphost = ENV['LDAPHOST']
    ENV['LDAPHOST'] = nil

    @ldapport = ENV['LDAPPORT']
    ENV['LDAPPORT'] = nil
  end

  after do
    ENV['LDAPURI']  = @ldapuri
    ENV['LDAPHOST'] = @ldaphost
    ENV['LDAPPORT'] = @ldapport
  end



  subject(:env) { ->{ described_class.new(uri) } }

  let(:uri) { nil }

  let(:opts) { env.call.to_h }



  describe 'When no ENV variables are set and URI ' do

    context 'is nil' do
      it 'sets host to localhost ip address' do
        expect(opts[:host]).to eql('127.0.0.1')
      end

      it 'infers standard port 389' do
        expect(opts[:port]).to eql(389)
      end

      it 'sets path to nil' do
        expect(opts[:path]).to eql(nil)
      end
    end

    context 'is LDAP with hostname and port' do
      let(:uri) { 'ldap://example.com:9999' }

      it { is_expected.not_to raise_error }

      it 'sets host' do
        expect(opts[:host]).to eql('example.com')
      end

      it 'sets port' do
        expect(opts[:port]).to eql(9999)
      end

      it 'sets path to nil' do
        expect(opts[:path]).to eql(nil)
      end
    end

    context 'is LDAPS with IP and no port' do
      let(:uri) { 'ldaps://127.0.0.1' }

      it { is_expected.not_to raise_error }

      it 'sets host to ip address' do
        expect(opts[:host]).to eql('127.0.0.1')
      end

      it 'infers standard port 636' do
        expect(opts[:port]).to eql(636)
      end

      it 'sets path to nil' do
        expect(opts[:path]).to eql(nil)
      end
    end

    context 'has invalid protocol' do
      let(:uri) { 'ldapx://127.0.0.1:10389' }

      it { is_expected.to raise_error(Dry::Types::ConstraintError) }
    end

  end


  describe 'When variables' do

    context 'URI, HOST and PORT are set' do

      before do
        ENV['LDAPURI'] = 'ldap://example.com:9999'
        ENV['LDAPHOST'] = 'foo.bar'
        ENV['LDAPPORT'] = '121212'
      end

      it 'URI sets host' do
        expect(opts[:host]).to eql('example.com')
      end

      it 'URI sets port' do
        expect(opts[:port]).to eql(9999)
      end
    end


    context 'HOST and PORT are set' do

      before do
        ENV['LDAPHOST'] = 'foo.baz'
        ENV['LDAPPORT'] = '343434'
      end

      it 'HOST sets host' do
        expect(opts[:host]).to eql('foo.baz')
      end

      it 'PORT sets port' do
        expect(opts[:port]).to eql(343434)
      end
    end

  end


  context 'Unix socket path' do
    let(:uri) { 'ldap:///var/run/ldap.sock' }

    it { is_expected.not_to raise_error }

    it 'sets port to nil' do
      expect(opts[:port]).to eql(nil)
    end

    it 'sets host to nil' do
      expect(opts[:host]).to eql(nil)
    end

    it 'sets path to filepath' do
      expect(opts[:path]).to eql('/var/run/ldap.sock')
    end
  end


end
