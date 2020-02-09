RSpec.describe ROM::LDAP::Types do

  describe 'Address' do
    subject(:type) { ROM::LDAP::Types::Address }

    it 'splits on $' do
      expect(type['street$town$region$country']).to eq(%w[
        street
        town
        region
        country
      ])
      expect(type['']).to eq([])
      expect(type['single_line_address']).to eq(%w[single_line_address])
    end
  end

  describe 'Time' do
    subject(:type) { ROM::LDAP::Types::Time }

    it 'ignores nil values' do
      expect(type[nil]).to be_nil
    end

    # oid:1.3.6.1.4.1.1466.115.121.1.24
    it 'coerces GeneralizedTime' do
      expect(type['20181109175836.147Z'].to_s).to eq('2018-11-09 17:58:36 UTC')
      expect(type['20020514230000Z'].to_s).to eq('2002-05-14 23:00:00 UTC')
    end

    it 'coerces Active Directory timestamps' do
      expect(type['131862601330000000'].to_s).to eq('2018-11-09 18:02:13 UTC')
      expect(type[0].to_s).to eql('1601-01-01 00:00:00 UTC')
    end
  end

  describe 'Bool' do
    subject(:type) { ROM::LDAP::Types::Bool }

    it 'coerces true values' do
      expect(type[true]).to be(true)
      expect(type['t']).to be(true)
      expect(type['TRUE']).to be(true)
      expect(type['y']).to be(true)
      expect(type['yes']).to be(true)
    end

    it 'coerces false values' do
      expect(type[false]).to be(false)
      expect(type['f']).to be(false)
      expect(type['FALSE']).to be(false)
      expect(type['n']).to be(false)
      expect(type['no']).to be(false)
    end
  end

  describe 'Binary' do
    subject(:type) { ROM::LDAP::Types::Binary }

    # 'convert -size 1x1 xc:white /tmp/pixel.jpg'
    it 'encodes to base64' do
      test_image = SPEC_ROOT.join('fixtures/pixel.jpg')
      image_data = File.binread(test_image)
      value = [image_data]

      expect(type[value]).to eql('/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/wAALCAABAAEBAREA/8QAFAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEAAD8AVN//2Q==')
    end
  end
end
