RSpec.describe ROM::LDAP::Directory, 'operations' do

  include_context 'vendor', 'apache_ds'

  it 'using the correct base' do
    expect(base).to eql('ou=specs,dc=rom,dc=ldap')
  end

  describe '#query' do
    it 'accepts :filter keyword' do
      expect(directory.query(filter: '(cn=*)', attributes: %w'species')).to be_empty
    end

    it 'default :filter keyword is "(objectClass=*)"' do
      expect(directory.query).to be_an(Array)
      expect(directory.query.size).to eql(1)
    end

    it ':base keyword changes search scope' do
      expect(directory.query(filter: '(m-name=discoveryDate)', base: 'cn=wildlife,ou=schema').first['m-oid']).to eql(%w[1.3.6.1.4.1.18055.0.4.1.2.1008])
    end

    it 'returns the whole tree when the :base keyword is empty' do
      expect(directory.query(base: '').count).to be > 1_000
      expect(directory.query(base: '').map(&:dn)).to include('dc=rom,dc=ldap')
      expect(directory.query(base: '').map(&:dn)).to include('uid=admin,ou=system')
      expect(directory.query(base: '').map(&:dn)).to include('cn=core,ou=schema')
      expect(directory.query(base: '').map(&:dn)).to include('ads-partitionId=rom-ldap,ou=partitions,ads-directoryServiceId=default,ou=config')
    end
  end


  describe '#find' do
    # species schema defintion.
    it 'searches whole tree' do
      oid = 'm-oid=1.3.6.1.4.1.18055.0.4.1.2.1001,ou=attributeTypes,cn=wildlife,ou=schema'
      expect(directory.find(oid)).to be_a(ROM::LDAP::Directory::Entry)
    end
  end

end
