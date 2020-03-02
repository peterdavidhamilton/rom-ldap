RSpec.describe ROM::LDAP::Directory::ENV do

  after do
    ENV['LDAPURI']    = nil
    ENV['LDAPHOST']   = nil
    ENV['LDAPPORT']   = nil
    ENV['LDAPBASE']   = nil
    ENV['LDAPBINDDN'] = nil
    ENV['LDAPBINDPW'] = nil
  end

  let(:uri) { nil }
  let(:config) { {} }
  let(:env) { described_class.new(uri, config) }

  subject(:opts) { env.to_h }

  describe 'Using ENV vars and inferrence' do
    context 'with unset variables' do
      it { is_expected.to include(host: 'localhost') }
      it { is_expected.to include(port: 389) }
      it { is_expected.to include(ssl: nil) }
      it { is_expected.to include(path: nil) }
    end

    context 'with LDAPURI=ldap://example.com:9389' do
      before { ENV['LDAPURI'] = 'ldap://example.com:9389' }

      it { is_expected.to include(host: 'example.com') }
      it { is_expected.to include(port: 9389) }
      it { is_expected.to include(ssl: nil) }
      it { is_expected.to include(path: nil) }
    end

    context 'with LDAPHOST=example.com' do
      before { ENV['LDAPHOST'] = 'example.com' }

      it { is_expected.to include(host: 'example.com') }
      it { is_expected.to include(port: 389) }
      it { is_expected.to include(ssl: nil) }
      it { is_expected.to include(path: nil) }
    end

    context 'with LDAPPORT=9389' do
      before { ENV['LDAPPORT'] = '9389' }

      it { is_expected.to include(host: 'localhost') }
      it { is_expected.to include(port: 9389) }
      it { is_expected.to include(ssl: nil) }
      it { is_expected.to include(path: nil) }
    end
  end


  describe 'Using a Gateway URL' do
    context 'of ldaps://127.0.0.1' do
      let(:uri) { 'ldaps://127.0.0.1' }
      let(:config) { { ssl: :foo } }

      it { is_expected.to include(host: '127.0.0.1') }
      it { is_expected.to include(port: 636) }
      it { is_expected.to include(ssl: :foo) }
      it { is_expected.to include(path: nil) }
    end

    context 'of ldap:///var/run/ldap.sock' do
      let(:uri) { 'ldap:///var/run/ldap.sock' }

      it { is_expected.to include(host: nil) }
      it { is_expected.to include(port: nil) }
      it { is_expected.to include(ssl: nil) }
      it { is_expected.to include(path: '/var/run/ldap.sock') }
    end

    context 'with a username containing a space' do
      let(:uri) { 'ldap://cn=Prince Adam@greyskull.net' }
      specify { expect { subject }.to_not raise_error }
    end

    context 'with an invalid protocol' do
      let(:uri) { 'ldapx://127.0.0.1:10389' }
      specify { expect { subject }.to raise_error(Dry::Types::ConstraintError) }
    end
  end


  # NB: LDAPHOST and LDAPPORT have no effect
  #
  describe 'Overriding a Gateway' do
    let(:uri) { 'ldap://cn=prince-adam:cringer@greyskull.net' }

    context 'with LDAPBASE=dc=grey,dc=skull' do
      before { ENV['LDAPBASE'] = 'dc=grey,dc=skull' }
      specify { expect(env.base).to eql('dc=grey,dc=skull') }
    end

    context 'with base: dc=grey,dc=skull' do
      let(:config) { { base: 'dc=grey,dc=skull' } }
      specify { expect(env.base).to eql('dc=grey,dc=skull') }
    end

    context 'with LDAPBINDDN=he-man' do
      before { ENV['LDAPBINDDN'] = 'he-man' }
      specify { is_expected.to include(auth: { username: 'he-man', password: 'cringer' }) }
    end

    context 'with username: he-man' do
      let(:config) { { username: 'he-man' } }
      specify { is_expected.to include(auth: { username: 'he-man', password: 'cringer' }) }
    end

    context 'with LDAPBINDPW=B@ttl3C4t' do
      before { ENV['LDAPBINDPW'] = 'B@ttl3C4t' }
      specify { is_expected.to include(auth: { username: 'cn=prince-adam', password: 'B@ttl3C4t' }) }
    end

    context 'with password: B@ttl3C4t' do
      let(:config) { { password: 'B@ttl3C4t' } }
      specify { is_expected.to include(auth: { username: 'cn=prince-adam', password: 'B@ttl3C4t' }) }
    end

    context 'with LDAPHOST=snake-mountain.net' do
      before { ENV['LDAPHOST'] = 'snake-mountain.net' }
      it { is_expected.to include(host: 'greyskull.net') }
      it { is_expected.to_not include(host: 'snake-mountain.net') }
    end

    context 'with LDAPPORT=121212' do
      before { ENV['LDAPPORT'] = '121212' }
      it { is_expected.to include(port: 389) }
      it { is_expected.to_not include(port: 121212) }
    end

  end
end
