RSpec.describe ROM::LDAP::ConnectionError do

  include_context 'directory'

  context 'correct server' do
    it 'raises no error' do
      expect { container }.not_to raise_error
    end
  end

  context 'incorrect server' do
    let(:uri) { 'ldap://127.0.0.1:9999' }

    it 'raises connection error' do
      expect { container }.to raise_error(
        ROM::LDAP::ConnectionError, 'Connection refused - 127.0.0.1:9999'
      )
    end
  end

end
