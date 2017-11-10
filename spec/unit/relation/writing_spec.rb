require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do
  include_context 'relations'

  describe '#insert' do
    let(:formatter) { old_format_proc }

    it '#update and #delete return an empty array for an empty dataset' do
      expect(accounts.where(uid: 'foo').update(mail: 'foo@bar')).to eql([])
      expect(accounts.where(uid: 'bar').delete).to eql([])
    end

    it '#insert -> #update -> #delete' do
      expect do
        accounts.insert(cn: 'The Dark Knight')
      end.to raise_error(ROM::LDAP::OperationError, 'distinguished name is required')

      expect(accounts.insert(
               dn: 'uid=batman,ou=users,dc=example,dc=com',
               cn: 'The Dark Knight',
               uid: 'batman',
               sn: 'Wayne',
               uidnumber: 1003,
               gidnumber: 1050,
               'apple-imhandle': 'bruce-wayne',
               objectclass: %w[extensibleobject inetorgperson apple-user]
      )).to be(true)

      expect(accounts.where(uid: 'batman').one[:cn]).to eql(['The Dark Knight'])
      expect(accounts.where(uid: 'batman').one[:appleimhandle]).to eql(['bruce-wayne'])
      expect(accounts.where(uid: 'batman').update(missing: 'Hulk')).to eql([false])
      expect(accounts.where(uid: 'batman').update(sn: 'Stark')).to eql([true])
      expect(accounts.where(uid: 'batman').one[:sn]).to eql(['Stark'])
      expect(accounts.where(uid: 'batman').delete).to eql([true])
      expect(accounts.where(uid: 'batman').one).to be_nil
    end
  end
end
