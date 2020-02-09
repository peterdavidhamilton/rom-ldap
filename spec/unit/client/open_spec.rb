RSpec.describe ROM::LDAP::Client, '#open' do

  # include_context 'directory'
  include_context 'vendor', 'open_ldap'

  let(:host) { URI(uri).host }
  let(:port) { URI(uri).port }
  let(:auth) { nil }
  let(:ssl)  { nil }

  subject(:client) do
    described_class.new(host: host, port: port, path: nil, auth: auth, ssl: ssl)
  end

  it 'raise error with no block' do
    expect { client.open }.to raise_error(
      LocalJumpError, 'no block given (yield)')
  end

  context 'when credentials are valid' do
    it 'yields a Socket' do
      expect { |b| client.open(&b) }.to yield_with_args(::Socket)
    end
  end

  context 'when credentials are invalid' do
    let(:auth) { { username: 'unknown', password: 'wrong' } }

    it 'raises ConfigError' do
      expect { |b| client.open(&b) }.to raise_error(
        ROM::LDAP::ConfigError, 'Authentication failed for unknown')
    end
  end

  context 'when protocol is encrypted' do
    let(:ssl) { OpenSSL::SSL::SSLContext::DEFAULT_PARAMS }

    xit 'yields a Socket' do
      expect { |b| client.open(&b) }.to yield_with_args(::Socket)
    end
  end

end
