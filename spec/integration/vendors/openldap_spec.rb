RSpec.describe 'OpenLDAP' do

  include_context 'directory'

  # let(:uri) { 'ldaps://192.168.99.102:2389' }
  # let(:bind_dn) { 'cn=admin,dc=rom,dc=ldap' }
  # let(:bind_pw) { 'topsecret' }

  xit 'vendor extension' do
    expect(directory.vendor_name).to eql('OpenLDAP')
    expect(directory.vendor_version).to eql('0.0')
  end

  xit 'reveals directory vendor name' do
    expect(conf.gateways[:default].directory_type).to eql(:open_ldap)
  end
end


# RSpec.describe 'OpenLDAP' do

#   let(:gateway) do
#     TestConfiguration.new(:ldap,
#       'ldaps://192.168.99.102:2389',
#       username: 'cn=admin,dc=rom,dc=ldap',
#       password: 'topsecret'
#     ).gateways[:default]
#   end

#   it 'vendor extension' do
#     expect(gateway.directory.vendor_name).to eql('OpenLDAP')
#     expect(gateway.directory.vendor_version).to eql('0.0')
#   end

#   it 'reveals directory vendor name' do
#     expect(gateway.directory_type).to eql(:open_ldap)
#     expect(gateway.directory.type).to eql(:open_ldap)
#   end
# end
