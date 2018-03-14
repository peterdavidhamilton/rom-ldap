RSpec.describe 'Commands / Delete' do

  let(:formatter) { method_name_proc }

  include_context 'relations'

  let(:account_commands) { commands[:accounts] }

  let(:delete_account) { account_commands.delete }

  before do
    conf.commands(:accounts) do
      define(:delete) do
        result :one
      end
    end

    accounts.insert(
      dn: 'uid=black_panther,ou=users,dc=example,dc=com',
      cn: 'King of Wakanda',
      uid: 'black_panther',
      givenname: "T'Challa",
      sn: 'Udaku',
      uidnumber: 1004,
      gidnumber: 1050,
      objectclass: %w[extensibleobject inetorgperson]
    )
  end

  after  { accounts.where(uid: 'black_panther').delete }

  describe '#call' do
    it 'deletes all tuples in a restricted relation' do
      entry  = delete_account.by_uid('black_panther').call
      result = entry.select(:uidnumber, :uid).to_s

      expect(result).to eql("uidnumber: 1004\nuid: black_panther\n\n")
    end

    it 're-raises database error' do
      command = delete_account.by_uid('black_panther')

      expect(command.relation).to receive(:delete).and_raise(
        ROM::LDAP::OperationError, 'distinguished name not found'
      )

      expect {
        command.call
      }.to raise_error(ROM::LDAP::OperationError, /distinguished name not found/)
    end
  end

end
