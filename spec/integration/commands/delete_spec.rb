RSpec.describe 'Commands / Delete' do

  before { skip('awaiting redesign') }

  # let(:formatter) { method_formatter }

  # include_context 'relations'

  before do
    # conf.relation(:accounts) do
    #   schema('(&(objectClass=person)(uid=*))', as: :accounts, infer: true) do
    #     attribute :uid, ROM::LDAP::Types::String.meta(index: true)
    #   end
    #   auto_struct false
    # end

    conf.commands(:accounts) do
      define(:delete) do
        result :one
      end
    end

    accounts.insert(
      dn: 'uid=black_panther,ou=users,dc=rom,dc=ldap',
      cn: 'King of Wakanda',
      uid: 'black_panther',
      givenname: "T'Challa",
      sn: 'Udaku',
      uidnumber: 1004,
      gidnumber: 1050,
      objectclass: %w[extensibleobject inetorgperson]
    )
  end

  let(:account_commands) { commands[:accounts] }

  let(:delete_account) { account_commands.delete }

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
