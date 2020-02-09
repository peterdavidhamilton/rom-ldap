RSpec.describe ROM::LDAP::Directory::ENV do

  after do
    ENV['LDAPURI']    = nil
    ENV['LDAPHOST']   = nil
    ENV['LDAPPORT']   = nil
    ENV['LDAPBASE']   = nil
    ENV['LDAPBINDDN'] = nil
    ENV['LDAPBINDPW'] = nil
  end

  let(:uri)    { nil }
  let(:config) { {} }
  let(:env)    { described_class.new(uri, config) }
  let(:opts)   { env.to_h }


  describe 'defaults' do
    context 'when no variables are set' do
      it 'infers localhost' do
        expect(opts[:host]).to eql('localhost')
      end

      it 'infers port 389' do
        expect(opts[:port]).to eql(389)
      end
    end
  end



  describe 'LDAPS protocol' do
    let(:uri) { 'ldaps://127.0.0.1' }
    let(:config) { { ssl: :foo } }

    it 'infers port 636' do
      expect(opts[:port]).to eql(636)
    end

    it 'includes ssl config' do
      expect(opts[:ssl]).to eql(:foo)
    end
  end



  describe 'spaces in LDAPURI username' do
    let(:uri) { 'ldap://cn=Prince Adam@greyskull.net' }

    subject(:env) { ->{ described_class.new(uri) } }

    it { is_expected.to_not raise_error }
  end


  describe 'invalid protocol' do
    let(:uri) { 'ldapx://127.0.0.1:10389' }

    subject(:env) { ->{ described_class.new(uri) } }

    it { is_expected.to raise_error(Dry::Types::ConstraintError) }
  end


  describe 'UNIX socket' do
    let(:uri) { 'ldap:///var/run/ldap.sock' }

    it '#port == nil' do
      expect(opts[:port]).to eql(nil)
    end

    it '#host == nil' do
      expect(opts[:host]).to eql(nil)
    end

    it '#path /var/run/ldap.sock' do
      expect(opts[:path]).to eql('/var/run/ldap.sock')
    end
  end



  describe 'optional overrides' do
    let(:uri) { 'ldap://cn=prince-adam:cringer@greyskull.net' }

    context 'LDAPBASE variable and LDAPURI' do
      before { ENV['LDAPBASE'] = 'dc=grey,dc=skull' }

      it 'overrides' do
        expect(env.base).to eql('dc=grey,dc=skull')
      end
    end

    context 'base option and LDAPURI' do
      let(:config) { { base: 'dc=grey,dc=skull' } }

      it 'overrides' do
        expect(env.base).to eql('dc=grey,dc=skull')
      end
    end


    context 'LDAPBINDDN variable and LDAPURI' do
      before { ENV['LDAPBINDDN'] = 'he-man' }

      it 'overrides' do
        expect(opts[:auth][:username]).to eql('he-man')
      end
    end

    context 'username option and LDAPURI' do
      let(:config) { { username: 'he-man' } }

      it 'overrides' do
        expect(opts[:auth][:username]).to eql('he-man')
      end
    end


    context 'LDAPBINDPW variable and LDAPURI' do
      before { ENV['LDAPBINDPW'] = 'B@ttl3C4t' }

      it 'overrides' do
        expect(opts[:auth][:password]).to eql('B@ttl3C4t')
      end
    end

    context 'password option and LDAPURI' do
      let(:config) { { password: 'B@ttl3C4t' } }

      it 'overrides' do
        expect(opts[:auth][:password]).to eql('B@ttl3C4t')
      end
    end


    describe 'LDAPHOST variable' do
      before { ENV['LDAPHOST'] = 'snake-mountain.net' }

      context 'and LDAPURI' do
        it 'does nothing' do
          expect(opts[:host]).to eql('greyskull.net')
        end
      end

      context 'without LDAPURI' do
        let(:uri) { nil }

        it 'overrides' do
          expect(opts[:host]).to eql('snake-mountain.net')
        end
      end
    end



    describe 'LDAPPORT variable' do
      before { ENV['LDAPPORT'] = '121212' }

      context 'and LDAPURI' do
        it 'does nothing' do
          expect(opts[:port]).to eql(389)
        end
      end

      context 'without LDAPURI' do
        let(:uri) { nil }

        it 'overrides' do
          expect(opts[:port]).to eql(121212)
        end
      end
    end

  end
end
