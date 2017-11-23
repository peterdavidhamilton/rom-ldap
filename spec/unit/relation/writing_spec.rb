require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do

  describe '#insert' do

    let(:formatter) { downcase_proc }
    include_context 'relations'

    before { accounts.where(uid: 'batman').delete }
    after  { accounts.where(uid: 'batman').delete }

    it '#update and #delete return an empty array for an empty dataset' do
      expect(accounts.where(uid: 'foo').update(mail: 'foo@bar')).to eql([])
      expect(accounts.where(uid: 'bar').delete).to eql([])
    end

    it '#insert -> #update -> #delete' do
      expect { accounts.insert(cn: 'The Dark Knight') }.to raise_error(
        ROM::LDAP::OperationError, 'distinguished name is required'
      )

      expect(
        accounts.insert(
          dn: 'uid=batman,ou=users,dc=example,dc=com',
          cn: 'The Dark Knight',
          uid: 'batman',
          sn: 'Wayne',
          uidnumber: 1003,
          gidnumber: 1050,
          appleimhandle: 'bruce-wayne',
          objectclass: %w[extensibleobject inetorgperson apple-user]
        )
      ).to be_kind_of(ROM::LDAP::Directory::Entity)

      expect(accounts.where(uid: 'batman').one[:cn]).to eql(['The Dark Knight'])
      expect(accounts.where(uid: 'batman').one[:appleimhandle]).to eql(['bruce-wayne'])
      expect(accounts.where(uid: 'batman').update(missing: 'Hulk')).to eql([false])

      expect(accounts.where(uid: 'batman').update(sn: 'Stark').to_s).to eql(
        "[{:dn=>[\"uid=batman,ou=users,dc=example,dc=com\"], :sn=>[\"Stark\"], :appleimhandle=>[\"bruce-wayne\"], :cn=>[\"The Dark Knight\"], :objectclass=>[\"top\", \"extensibleobject\", \"person\", \"organizationalPerson\", \"inetorgperson\", \"apple-user\"], :gidnumber=>[\"1050\"], :uidnumber=>[\"1003\"], :uid=>[\"batman\"]}]"
      )

      expect(accounts.where(uid: 'batman').delete).to eql([true])
      expect(accounts.where(uid: 'batman').one).to be_nil
    end
  end
end
