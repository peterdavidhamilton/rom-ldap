require 'rom/lint/spec'

RSpec.describe ROM::LDAP::Gateway do

  include_context 'dragons'

  it_behaves_like 'a rom gateway' do
    let(:identifier) { :ldap }
    let(:gateway) { ROM::LDAP::Gateway }
  end


  let(:gateway) { container.gateways[:default] }

  describe 'with minimal options' do
    it 'establishes an LDAP connection' do
      gateway = ROM::LDAP::Gateway.new(uri, gateway_opts)
      expect(gateway).to be_instance_of(ROM::LDAP::Gateway)
    end
  end

  describe '#dataset?' do
    it 'returns true if a entries exist' do
      expect(gateway.dataset?('(cn=*)')).to be(true)
    end

    it 'returns false if entries do not exist' do
      expect(gateway.dataset?('(foo=bar)')).to be(false)
    end
  end


  describe 'authenticated connection' do
    let(:gateway) { ROM::LDAP::Gateway.new(uri, auth_gateway_opts) }

    context 'with valid credentials' do
      let(:auth_gateway_opts) do
        {
          **gateway_opts,
          username: 'uid=admin,ou=system',
          password: 'secret',
        }
      end

      it 'binds to server' do
        expect(gateway.dataset('(genus=*)').to_a).to_not be_empty
      end
    end

    context 'with invalid credentials' do
      let(:auth_gateway_opts) do
        {
          **gateway_opts,
          username: 'uid=admin,ou=system',
          password: 'wrong password',
        }
      end

      it 'raises error' do
        expect { gateway.dataset('(genus=*)').to_a }.to raise_error(
          ROM::LDAP::ConfigError,
          'Authentication failed for uid=admin,ou=system'
          )
      end
    end
  end


  describe '#disconnect' do
    let(:gateway) { ROM::LDAP::Gateway.new(uri, gateway_opts) }

    it 'closes client connection' do
      expect(gateway.directory.client).to receive(:close)
      gateway.disconnect
    end
  end

  describe '#call' do
    it 'queries for attributes' do
      expect(gateway.('(description=*)')).to be_an(Array)
      expect(gateway.('(description=*)').size).to eql(1)
    end
  end

end
