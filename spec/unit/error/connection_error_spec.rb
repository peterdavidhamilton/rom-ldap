RSpec.describe ROM::LDAP::ConnectionError do

  include_context 'directory'

  context 'correct server' do
    it 'raises no error' do
      expect { container }.not_to raise_error
    end
  end

  context 'incorrect server' do
    let(:uri) { 'ldaps://127.0.0.1:6389' }

    it 'raises connection error' do
      expect { container }.to raise_error(
        ROM::LDAP::ConnectionError,
        'Connection failed - 127.0.0.1:6389'
      )
    end
  end

end
