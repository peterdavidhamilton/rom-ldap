RSpec.describe ROM::LDAP::Directory::Entry do

  with_vendors do

    subject(:entry) { directory.query.first }

    it 'returned by directory#query' do
      expect(entry).to be_a(described_class)
    end

    it '#dn' do
      expect(entry.dn).to eql('ou=specs,dc=rom,dc=ldap')
    end

    it '#[]' do
      expect(entry[:object_class]).to include('organizationalUnit')
      expect(entry['objectClass']).to include('organizationalUnit')
    end

    it '#fetch' do
      expect(entry.fetch(:object_class)).to include('organizationalUnit')
      expect(entry.fetch('objectClass')).to include('organizationalUnit')
    end

    it '#first' do
      case vendor
      when 'apache_ds', 'open_dj'
        expect(entry.first(:object_class)).to eql('top')
        expect(entry.first('objectClass')).to eql('top')
      when 'open_ldap', '389_ds'
        expect(entry.first(:object_class)).to eql('organizationalUnit')
        expect(entry.first('objectClass')).to eql('organizationalUnit')
      end
    end

    it '#each_value' do
      expect(entry.each_value(:object_class, &:to_sym)).to include(:organizationalUnit)
      expect(entry.each_value('objectClass', &:to_sym)).to include(:organizationalUnit)
    end

    it '#keys' do
      expect(entry.keys).to eql(%i'dn object_class ou')
    end

    it '#to_h' do
      expect(entry.to_h).to match(a_hash_including(
        dn: ['ou=specs,dc=rom,dc=ldap'],
        ou: ['specs']
      ))
    end


    context 'when unformatted' do
      before { ROM::LDAP.use_formatter(nil) }

      it 'attributes must be canonical' do
        expect(entry['ou']).to eql(%w'specs')
        expect(entry[:ou]).to be_nil
        expect(entry.first(:object_class)).to be_nil
      end
    end

  end
end
