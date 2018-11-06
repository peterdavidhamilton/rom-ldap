RSpec.describe ROM::LDAP::ConnectionError do

  include_context 'directory'

  before do
    conf.relation(:foo) { schema('(dn=*)') }
  end

  context 'correct server' do
    it 'raises no error' do
      expect { container.relations }.not_to raise_error
    end
  end

  context 'incorrect server' do

    let(:servers) { %w'127.0.0.1:6389' }

    it 'raises connection error' do
      expect { container.relations }.
        to raise_error(ROM::LDAP::ConnectionError, 'Connection failed: 127.0.0.1:6389')
    end
  end

end
