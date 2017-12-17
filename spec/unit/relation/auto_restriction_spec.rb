RSpec.describe ROM::LDAP::Relation do

  include_context 'relations'

  let(:formatter) { nil }

  it '#by_uidNumber' do
    expect(customers.by_uidNumber(1).one['entryDN']).to eql('uid=test1,ou=users,dc=example,dc=com')
  end

  it '#by_uid' do
    expect(customers.by_uid('test2').one['entryDN']).to eql('uid=test2,ou=users,dc=example,dc=com')
  end

  it '#by_cn' do
    expect(customers.by_cn('test3').one['entryDN']).to eql('uid=test3,ou=users,dc=example,dc=com')
  end

    it '#by_givenName' do
    expect(customers.by_givenName('test4').one['entryDN']).to eql('uid=test4,ou=users,dc=example,dc=com')
  end
end
