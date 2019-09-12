RSpec.describe '389DS' do

  let(:gateway) do
    TestConfiguration.new(:ldap,
      'ldap://389ds/ou=specs,dc=rom,dc=ldap',
      username: 'cn=Directory Manager',
      password: 'topsecret'
    ).gateways[:default]
  end

  it '#type' do
    expect(gateway.directory.type).to eql(:three_eight_nine)
  end

  it '#od?' do
    expect(gateway.directory.od?).to eql(false)
  end

  it '#ad?' do
    expect(gateway.directory.od?).to eql(false)
  end

  describe 'extension' do
    it '#vendor_name' do
      expect(gateway.directory.vendor_name).to eql('389 Project')
    end

    it '#vendor_version' do
      expect(gateway.directory.vendor_version).to match(/^389-Directory\/1.3.8.4 B[\d.]+$/)
    end
  end

end
