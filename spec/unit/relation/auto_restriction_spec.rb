RSpec.describe ROM::LDAP::Relation do

  include_context 'directory'

  before do
    ROM::LDAP::Directory::Entry.use_formatter(nil)

    conf.relation(:foo) do
      schema(users, infer: true) do
        attribute :cn,        ROM::LDAP::Types::String.meta(index: true)
        attribute :uid,       ROM::LDAP::Types::String.meta(index: true)
        attribute :givenName, ROM::LDAP::Types::String.meta(index: true)
        attribute :uidNumber, ROM::LDAP::Types::Integer.meta(index: true)
      end
    end
  end

  let(:relation) { relations[:foo] }

  it '#by_cn' do
    expect(relation.by_cn('test3').one['entryDN']).to eql('uid=test3,ou=users,dc=example,dc=com')
  end

  it '#by_uid' do
    expect(relation.by_uid('test2').one['entryDN']).to eql('uid=test2,ou=users,dc=example,dc=com')
  end

  it '#by_givenName' do
    expect(relation.by_givenName('test4').one['entryDN']).to eql('uid=test4,ou=users,dc=example,dc=com')
  end

  it '#by_uidNumber' do
    expect(relation.by_uidNumber(1).one['entryDN']).to eql('uid=test1,ou=users,dc=example,dc=com')
  end
end
