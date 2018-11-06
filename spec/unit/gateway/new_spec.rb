RSpec.describe ROM::LDAP::Gateway do

  include_context 'directory'

  subject(:gateway) { ROM::LDAP::Gateway.new(gateway_opts) }

  it 'establishes connection' do
    expect(gateway.connection).to be_instance_of(ROM::LDAP::Connection)
  end

  it 'connects to the server' do
    expect(gateway.connection.alive?).to eql(true)
    expect(gateway.connection.servers).to eql(gateway_opts[:servers])
  end

  # @note Requires test suite to run against Apache Directory Studio
  it 'reveals directory vendor name' do
    expect(gateway.directory_type).to eql(:apache_ds)
  end

end
