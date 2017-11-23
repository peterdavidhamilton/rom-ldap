require 'spec_helper'

RSpec.describe ROM::LDAP::Gateway do
  include_context 'directory'

  subject(:gateway) { ROM::LDAP::Gateway.new(server, ldap_options) }

  it 'establishes connection' do
    expect(gateway.connection).to be_instance_of(ROM::LDAP::Connection)
  end

  it 'connects to the server' do
    expect(gateway.connection.servers).to eql([server[:server]])
  end

  it 'reveals directory vendor name' do
    expect(gateway.directory_type).to eql(:apacheds)
  end

  # it 'call' do
  #   binding.pry
  #   expect(gateway['(objectClass=*)']).to eql(:apacheds)
  # end

end
