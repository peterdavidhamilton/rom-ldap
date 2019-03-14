RSpec.describe ROM::LDAP::Gateway do

  include_context 'directory'

  subject(:gateway) { ROM::LDAP::Gateway.new(uri, gateway_opts) }

  it 'establishes a directory connection' do
    expect(gateway.directory).to be_instance_of(ROM::LDAP::Directory)
  end

  it 'reveals directory vendor name' do
    expect(gateway.directory_type).to eql(:apache_ds)
  end

end
