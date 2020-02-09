require 'rom/lint/spec'

RSpec.describe ROM::LDAP::Gateway do

  with_vendors do

    let(:gateway) { container.gateways[:default] }

    it_behaves_like 'a rom gateway' do
      let(:identifier) { :ldap }
      let(:gateway) { ROM::LDAP::Gateway }
    end


    it 'allows options to be passed to the directory' do
      gateway = described_class.new(uri, base: 'foo')
      expect(gateway.directory.base).to eql('foo')
    end

    it 'allows extensions' do
      extensions = [:compatibility, :dsml_export]

      expect(ROM::LDAP).to receive(:load_extensions).with(:compatibility)
      expect(ROM::LDAP).to receive(:load_extensions).with(:dsml_export)

      described_class.new(uri, extensions: extensions)
    end



    describe 'authenticated connection' do
      context 'with valid credentials' do
        it do
          expect { gateway.dataset('(objectClass=*)') }.to_not raise_error
        end
      end

      context 'with invalid credentials' do
        it do
          expect { described_class.new(uri, username: 'cn=Carnage') }.to raise_error(
            ROM::LDAP::ConfigError,
            'Authentication failed for cn=Carnage'
            )
        end
      end
    end



    describe '#dataset?' do

      before do
        directory.add(
          dn: "cn=Venom,#{base}",
          cn: 'Venom',
          sn: 'Brock',
          object_class: 'person'
        )
      end

      after do
        directory.delete("cn=Venom,#{base}")
      end

      context 'when entries exist' do
        it do
          expect(gateway.dataset('(objectclass=*)').count).to be > 0
          expect(gateway.dataset?('(objectclass=*)')).to be(true)
        end
      end

      context 'when entries do not exist' do
        it do
          expect(gateway.dataset('(foo=bar)').count).to be(0)
          expect(gateway.dataset?('(foo=bar)')).to be(false)
        end
      end
    end


    describe '#disconnect' do
      it 'closes client connection' do
        expect(gateway.directory.client).to receive(:close)
        gateway.disconnect
      end
    end

    describe '#call' do
      it 'queries for attributes' do
        expect(gateway.('(objectClass=*)')).to be_an(Array)
        expect(gateway.('(objectClass=*)')).to_not be_empty
      end
    end

    describe '#attribute_types' do
      subject { gateway.attribute_types }

      it { is_expected.to be_an(Array) }
      it { is_expected.to_not be_empty }
    end

  end
end
