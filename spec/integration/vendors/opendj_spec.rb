RSpec.describe 'OpenDJ' do

  let(:gateway) do
    TestConfiguration.new(:ldap,
      'ldap://opendj',
      username: 'cn=Directory Manager',
      password: 'topsecret'
    ).gateways[:default]
  end

  it '#type' do
    expect(gateway.directory.type).to eql(:open_dj)
  end

  it '#od?' do
    expect(gateway.directory.od?).to eql(false)
  end

  it '#ad?' do
    expect(gateway.directory.od?).to eql(false)
  end

  describe 'extension' do
    it '#vendor_name' do
      expect(gateway.directory.vendor_name).to eql('ForgeRock AS.')
    end

    it '#vendor_version' do
      expect(gateway.directory.vendor_version).to match(/^OpenDJ Server \d.\d.\d$/)
    end

    it '#full_vendor_version' do
      expect(gateway.directory.full_vendor_version).to match(/^\d.\d.\d.[a-f0-9]+$/)
    end

    it '#etag' do
      expect(gateway.directory.etag).to eql('00000000708a56d4')
    end
  end

end
