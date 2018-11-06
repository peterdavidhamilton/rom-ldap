RSpec.describe ROM::LDAP::Relation, 'Plugin::AutoRestrictions' do

  include_context 'directory'

  before do
    ROM::LDAP::Directory::Entry.use_formatter(nil)

    conf.relation(:foo) do
      schema('(objectClass=inetOrgPerson)') do
        attribute :cn,        ROM::LDAP::Types::String.meta(index: true)
        attribute :uid,       ROM::LDAP::Types::String.meta(index: true)
        attribute :givenName, ROM::LDAP::Types::String.meta(index: true)
        attribute :uidNumber, ROM::LDAP::Types::Integer.meta(index: true)
      end
    end
  end

  let(:relation) { relations.foo }

  it 'adds #by_attribute method' do
    expect(relation.respond_to?(:by_cn)).to be(true)
    expect(relation.respond_to?(:by_uid)).to be(true)
    expect(relation.respond_to?(:by_givenName)).to be(true)
    expect(relation.respond_to?(:by_uidNumber)).to be(true)
  end

  it 'uses the formatted attribute name only' do
    expect(relation.respond_to?(:by_given_name)).to be(false)
    expect(relation.respond_to?(:by_uid_number)).to be(false)
  end

  it 'uses (attr=val) criteria' do
    expect(relation.by_cn('test3').ldap_string).to match(/(cn=test3)/)
    expect(relation.by_uid('test2').ldap_string).to match(/(uid=test2)/)
    expect(relation.by_givenName('test4').ldap_string).to match(/(givenName=test4)/)
    expect(relation.by_uidNumber(1).ldap_string).to match(/(uidNumber=1)/)
  end
end
