#
# No formatter so directory and connection ops
# require canonical attribute names.
#
RSpec.describe ROM::LDAP::Directory do

  include_context 'directory'

  let(:dn) { "cn=Lucas Bishop,#{base}" }

  after do
    directory.delete(dn)
  end

  describe '#query' do
    it 'accepts :filter keyword' do
      expect(directory.query(filter: '(cn=*)', attributes: %w'species')).to be_empty
    end

    it 'defaults to base="", filter="(objectClass=*)"' do
      expect(directory.query).to be_an(Array)
    end

    it 'can search schema entries' do
      # VENDOR: apacheds
      expect(directory.query(filter: '(m-name=discoveryDate)', base: 'cn=wildlife,ou=schema').first['m-oid']).to eql(%w[1.3.6.1.4.1.18055.0.4.1.2.1008])
    end

    xit 'returns the whole tree to a max of 1_432' do
      expect(directory.query(base: '').count).to eql(1_432)
    end
  end


  describe '#add' do
    it 'persists valid entries' do
      # binding.pry
      expect(directory.add(dn: dn, cn: 'Lucas Bishop', sn: 'Bishop', objectClass: 'person')).to be_a(ROM::LDAP::Directory::Entry)
      expect(directory.find(dn)).to be_a(ROM::LDAP::Directory::Entry)
    end

    it "doesn't persist invalid entries" do
      expect(directory.add(dn: dn, cn: 'Lucas Bishop', objectClass: 'mutant')).to eql(false)
    end
  end


  describe '#modify' do
    xit 'can update an attribute schema' do
      expect(directory.modify('m-oid=1.3.6.1.4.1.18055.0.4.1.2.1001,ou=attributeTypes,cn=wildlife,ou=schema', m_single_value: false)).to eql([])
      expect(directory.modify('m-oid=1.3.6.1.4.1.18055.0.4.1.2.1001,ou=attributeTypes,cn=wildlife,ou=schema', m_single_value: true)).to eql([])
    end
  end


  describe '#delete' do
    before do
      directory.add(dn: dn, cn: 'Lucas Bishop', sn: 'Bishop', objectClass: 'person')
    end

    it 'destroys entries' do
      expect(directory.delete(dn)).to be_a(ROM::LDAP::Directory::Entry)
      expect(directory.delete(dn)).to be(false)
    end
  end

end
