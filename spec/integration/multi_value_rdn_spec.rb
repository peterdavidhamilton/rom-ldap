RSpec.describe 'Using an RDN with multiple values' do

  with_vendors do

    # NB: used when a single component RDN cannot be guaranteed unique

    let(:rdn) { "cn=Captain America+sn=Rogers,#{base}" }

    let(:entry) { directory.add(dn: rdn, objectclass: 'person') }

    after do
      directory.delete(rdn)
    end

    it 'creates an entry with those attributes' do
      expect(entry.to_h).to match(a_hash_including(cn: ['Captain America'], sn: %w'Rogers'))
    end

  end

end