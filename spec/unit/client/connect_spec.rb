RSpec.describe ROM::LDAP::Client, '#connect' do

  include_context 'directory'

  # let(:envs) {  }
  # let(:auth) {  }
  # let(:ssl) {  }

  let(:client) { described_class.new({ host: 'apacheds', port: 10389 }) }

  it 'raise error with no block' do
    expect { client.connect }.to raise_error(LocalJumpError, 'no block given (yield)')
  end

  xit 'yield Socket' do
    # expect(client.connect ).to yield_with_no_args
  end


end
