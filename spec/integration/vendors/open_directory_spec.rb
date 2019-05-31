RSpec.xdescribe 'OpenDirectory' do

  let(:gateway) do
    TestConfiguration.new(:ldap,
      'ldap://opendirectory',
      username: 'cn=diradmin,dc=rom,dc=ldap',
      password: 'password'
    ).gateways[:default]
  end

  it '#type' do
    expect(gateway.directory.type).to eql(:open_directory)
  end

  it '#od?' do
    expect(gateway.directory.od?).to eql(true)
  end

  it '#ad?' do
    expect(gateway.directory.od?).to eql(false)
  end

  # describe 'extension' do
  #   it '#vendor_name' do
  #     expect(gateway.directory.vendor_name).to eql('OpenLDAP')
  #   end

  #   it '#vendor_version' do
  #     expect(gateway.directory.vendor_version).to eql('0.0')
  #   end

  #   it '#organization' do
  #     expect(gateway.directory.organization).to eql('ROM-LDAP OpenLDAP Server')
  #   end
  # end
end
