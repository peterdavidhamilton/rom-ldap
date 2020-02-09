RSpec.describe ROM::LDAP::Directory, '#key_map' do

  include_context 'directory'

  subject(:keys) { directory.key_map }

  context 'when using the default formatter' do

    before { ROM::LDAP.use_formatter(nil) }
    after { ROM::LDAP.use_formatter(method_formatter) }

    it do
      expect(keys).to include('c-o' => 'c-o')
      expect(keys).to include('c-PostalCode' => 'c-PostalCode')
      expect(keys).to include('dSAQuality' => 'dSAQuality')
      expect(keys).to include('homeTelephoneNumber' => 'homeTelephoneNumber')
      expect(keys).to include('mXRecord' => 'mXRecord')
      expect(keys).to include('textEncodedORAddress' => 'textEncodedORAddress')
      expect(keys).to include('x500UniqueIdentifier' => 'x500UniqueIdentifier')
    end
  end


  context 'when using the compatibility formatter' do
    it do
      expect(keys).to include(c_o: 'c-o')
      expect(keys).to include(c_postal_code: 'c-PostalCode')
      expect(keys).to include(d_sa_quality: 'dSAQuality')
      expect(keys).to include(home_telephone_number: 'homeTelephoneNumber')
      expect(keys).to include(m_x_record: 'mXRecord')
      expect(keys).to include(text_encoded_or_address: 'textEncodedORAddress')
      expect(keys).to include(x500_unique_identifier: 'x500UniqueIdentifier')
    end
  end
end
