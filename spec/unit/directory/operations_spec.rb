RSpec.describe ROM::LDAP::Directory, 'operations' do

  let(:dn) { "cn=Lucas Bishop,#{base}" }

  after do
    directory.delete(dn)
  end

  with_vendors do

    describe '#add' do
      context 'when valid' do
        it 'returns created entry' do
          expect(directory.add(dn: dn, cn: 'Lucas Bishop', sn: 'Bishop', objectClass: 'person')).to be_a(ROM::LDAP::Directory::Entry)
          expect(directory.find(dn)).to be_a(ROM::LDAP::Directory::Entry)
        end
      end

      # NB: would require sn attribute to be valid.
      context 'when invalid' do
        it 'returns false' do
          expect(directory.add(dn: dn, cn: 'Lucas Bishop', objectClass: 'mutant')).to be(false)
        end
      end
    end

    describe '#modify' do
      before do
        directory.add(
          dn: dn,
          cn: 'Lucas Bishop',
          sn: 'Bishop',
          objectClass: 'person')
      end

      context 'when valid' do
        it 'returns created entry' do
          expect(directory.modify(dn, object_class: %w'person extensibleObject', given_name: 'Lucas')).to be_a(ROM::LDAP::Directory::Entry)
          expect(directory.find(dn)['givenName']).to eql(%w'Lucas')
          expect(directory.find(dn)[:object_class]).to include('extensibleObject')
        end

        it 'also replace the dn' do
          new_dn = "cn=Archbishop,#{base}"

          directory.modify(dn, dn: new_dn, cn: 'Archbishop')
          expect(directory.find(new_dn)).to include(cn: %w'Archbishop', sn: %w'Bishop')
          directory.delete(new_dn)
        end
      end

      # NB: would require additional objectclass to add this attribute.
      context 'when invalid' do
        it 'returns false' do
          expect(directory.modify(dn, given_name: 'Lucas')).to be(false)
          expect(directory.modify(dn, givenname: 'Lucas')).to be(false)
        end
      end
    end


    describe '#delete' do
      context 'when entry exists' do
        before do
          directory.add(
            dn: dn,
            cn: 'Lucas Bishop',
            sn: 'Bishop',
            objectClass: 'person')
        end

        it 'returns deleted entry' do
          expect(directory.delete(dn)).to be_a(ROM::LDAP::Directory::Entry)
        end
      end

      context 'when no entry exists' do
        it 'returns false' do
          expect(directory.delete(dn)).to be(false)
        end
      end
    end

  end
end
