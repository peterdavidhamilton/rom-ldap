RSpec.describe 'OpenDJ' do

  include_context 'directory'

  # let(:uri) { 'ldaps://192.168.99.102:4389' }
  # let(:bind_dn) { 'cn=Directory Manager' }
  # let(:bind_pw) { 'topsecret' }

  xit 'vendor extension' do
    expect(directory.vendor_name).to eql('ForgeRock AS.')
    expect(directory.vendor_version).to eql('OpenDJ Server 4.3.1')
  end

  xit 'reveals directory vendor name' do
    expect(conf.gateways[:default].directory_type).to eql(:open_dj)
  end
end


# RSpec.describe 'OpenDJ' do

#   let(:gateway) do
#     TestConfiguration.new(:ldap,
#       'ldaps://192.168.99.102:4389',
#       username: 'cn=Directory Manager',
#       password: 'topsecret'
#     ).gateways[:default]
#   end

#   it 'vendor extension' do
#     expect(gateway.directory.vendor_name).to eql('ForgeRock AS.')
#     expect(gateway.directory.vendor_version).to eql('OpenDJ Server 4.3.1')
#   end

#   it 'reveals directory vendor name' do
#     expect(gateway.directory_type).to eql(:open_dj)
#     expect(gateway.directory.type).to eql(:open_dj)
#   end
# end
