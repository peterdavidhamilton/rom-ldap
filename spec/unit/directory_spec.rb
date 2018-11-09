RSpec.describe ROM::LDAP::Directory do

  include_context 'directory'

  it 'searches schema entries' do
    expect(directory.query(filter: '(m-name=discoveryDate)', base: 'cn=wildlife,ou=schema')).to eql()
  end

  it 'returns the whole tree' do
    expect(directory.query(filter: '(objectClass=*)', base: '').count).to eql(1000)
  end

  it 'persists entries' do
    expect(directory.add(dn: 'cn=foobar,ou=specs,dc=rom,dc=ldap', cn: 'foobar', sn: 'foo', objectClass: 'person')).to eql(true)
  end

  it 'doesnt persist invalid entries' do
    expect(directory.add(dn: 'cn=foobar,ou=specs,dc=rom,dc=ldap', cn: 'foobar', objectClass: 'person')).to eql(false)
  end

  it 'can update an attribute schema' do
    directory.modify('m-oid=1.3.6.1.4.1.18055.0.4.1.2.1012,ou=attributeTypes,cn=wildlife,ou=schema', m_syntax: '1.3.6.1.4.1.1466.115.121.1.24')
  end
end
