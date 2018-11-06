RSpec.describe ROM::LDAP::Relation do

  describe '#insert downcase' do

    # let(:formatter) { downcase_formatter }

    # include_context 'relations'

    before { accounts.where(uid: 'batman').delete }
    after  { accounts.where(uid: 'batman').delete }

    it '#update and #delete return an empty array for an empty dataset' do
      expect(accounts.where(uid: 'foo').update(mail: 'foo@bar')).to eql([])
      expect(accounts.where(uid: 'bar').delete).to eql([])
    end

    it '#insert returns false on failure' do
      expect(
        accounts.insert(
          dn: 'uid=batman,ou=users,dc=example,dc=com',
          cn: 'The Dark Knight',
          uid: 'batman',
          sn: 'Wayne',
          objectclass: %w[top]
        )
      ).to eql(false)
    end

    it '#insert raises error if missing dn' do
      expect { accounts.insert(cn: 'The Dark Knight') }.to raise_error(
        ROM::LDAP::OperationError, 'distinguished name is required'
      )
    end

    it '#insert -> #update -> #delete' do
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
      ).to be_kind_of(ROM::LDAP::Directory::Entry)

      expect(accounts.where(uid: 'batman').one[:cn]).to eql(['The Dark Knight'])
      expect(accounts.where(uid: 'batman').one[:appleimhandle]).to eql(['bruce-wayne'])
      # expect(accounts.where(uid: 'batman').update(missing: 'Hulk')).to eql([false])
      # expect(accounts.where(uid: 'batman').update(sn: 'Stark').first.sn).to eql(['Stark'])
      # expect(accounts.where(uid: 'batman').delete).to eql([true])
      # expect(accounts.where(uid: 'batman').one).to be_nil
    end
  end

  describe '#insert snake_case' do

    # let(:formatter) { method_formatter }
    # include_context 'relations'

    before { accounts.where(uid: 'batman').delete }
    after  { accounts.where(uid: 'batman').delete }

    it '#update and #delete return an empty array for an empty dataset' do
      expect(accounts.where(uid: 'foo').update(mail: 'foo@bar')).to eql([])
      expect(accounts.where(uid: 'bar').delete).to eql([])
    end

    it '#insert raises error if missing dn' do
      expect { accounts.insert(cn: 'The Dark Knight') }.to raise_error(
        ROM::LDAP::OperationError, 'distinguished name is required'
      )
    end

    it '#insert -> #update -> #delete' do
      expect(
        accounts.insert(
          dn: 'uid=batman,ou=users,dc=example,dc=com',
          cn: 'The Dark Knight',
          uid: 'batman',
          sn: 'Wayne',
          uid_number: 1003,
          gid_number: 1050,
          apple_imhandle: 'bruce-wayne',
          object_class: %w[extensibleobject inetorgperson apple-user]
        )
      ).to be_kind_of(ROM::LDAP::Directory::Entry)

      expect(accounts.where(uid: 'batman').one[:cn]).to eql(['The Dark Knight'])
      expect(accounts.where(uid: 'batman').one[:apple_imhandle]).to eql(['bruce-wayne'])
      # expect(accounts.where(uid: 'batman').update(missing: 'Hulk')).to eql([false])
      # expect(accounts.where(uid: 'batman').update(sn: 'Stark').first.sn).to eql(['Stark'])
      # expect(accounts.where(uid: 'batman').delete).to eql([true])
      # expect(accounts.where(uid: 'batman').one).to be_nil
    end
  end
end
