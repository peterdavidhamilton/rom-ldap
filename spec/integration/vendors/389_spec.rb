RSpec.describe '389 DS' do

  include_context 'directory'

  # let(:uri) { 'ldaps://192.168.99.102:3389' }
  # let(:bind_dn) { 'cn=Directory Manager' }
  # let(:bind_pw) { 'topsecret' }

  xit 'vendor extension' do
    expect(directory.vendor_name).to eql('389 Project')
    expect(directory.vendor_version).to eql('389-Directory/1.3.8.4 B2018.332.2046')
  end

  xit 'reveals directory vendor name' do
    expect(conf.gateways[:default].directory_type).to eql(:three_eight_nine)
  end
end



# RSpec.describe '389 DS' do

#   let(:gateway) do
#     TestConfiguration.new(:ldap,
#       'ldaps://192.168.99.102:3389',
#       username: 'cn=Directory Manager',
#       password: 'topsecret'
#     ).gateways[:default]
#   end

#   it 'vendor extension' do
#     expect(gateway.directory.vendor_name).to eql('389 Project')
#     expect(gateway.directory.vendor_version).to eql('389-Directory/1.3.8.4 B2018.332.2046')
#   end

#   it 'reveals directory vendor name' do
#     expect(gateway.directory_type).to eql(:three_eight_nine)
#     expect(gateway.directory.type).to eql(:three_eight_nine)
#   end
# end
