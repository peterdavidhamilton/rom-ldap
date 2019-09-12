RSpec.xdescribe 'Active Directory' do

  let(:gateway) do
    TestConfiguration.new(:ldap,
      ENV['AD_URI'],
      username: ENV['AD_USER'],
      password: ENV['AD_PW']
    ).gateways[:default]
  end


  it '#type' do
    expect(gateway.directory.type).to eql(:active_directory)
  end

  it '#od?' do
    expect(gateway.directory.od?).to eql(false)
  end

  it '#ad?' do
    expect(gateway.directory.ad?).to eql(true)
  end


  describe 'extension' do
    it '#vendor_name' do
      expect(gateway.directory.vendor_name).to eql('Microsoft')
    end

    it '#vendor_version' do
      expect(gateway.directory.vendor_version).to eql('Windows Server 2008 R2 (6.1)')
    end

    it '#supported_capabilities' do
      expect(gateway.directory.supported_capabilities).to eql(%w[
        1.2.840.113556.1.4.1670
        1.2.840.113556.1.4.1791
        1.2.840.113556.1.4.1935
        1.2.840.113556.1.4.2080
        1.2.840.113556.1.4.2237
        1.2.840.113556.1.4.800
      ])
    end

    it '#forest_functionality' do
      expect(gateway.directory.forest_functionality).to eql(4)
    end

    it '#directory_time' do
      expect(gateway.directory.directory_time).to be_an_instance_of(Time)
      expect(gateway.directory.directory_time).to be_within(3600*1).of(Time.now.utc)
    end
  end

end
