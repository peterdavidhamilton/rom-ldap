RSpec.describe ROM::LDAP::Commands::Delete do

  with_vendors do

    before do
      conf.relation(:accounts) do
        schema('(objectClass=person)', infer: true) do
          attribute :uid, ROM::LDAP::Types::Strings.meta(index: true)
        end
        auto_struct false
      end

      conf.commands(:accounts) do
        define(:delete) do
          result :one
        end
      end

      relations[:accounts].insert(
        dn: 'uid=black_panther,ou=specs,dc=rom,dc=ldap',
        cn: 'King of Wakanda',
        uid: 'black_panther',
        given_name: "T'Challa",
        sn: 'Udaku',
        object_class: %w[extensibleobject inetorgperson]
      )
    end

    let(:account_commands) { commands[:accounts] }
    let(:delete_account) { account_commands.delete }

    after do
      relations[:accounts].where(uid: 'black_panther').delete
    end

    describe '#call' do
      it 'deletes all tuples in a restricted relation' do
        entry = delete_account.by_uid('black_panther').call

        expect(entry).to be_a(ROM::LDAP::Directory::Entry)
        expect(entry[:uid]).to eql(['black_panther'])
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

end
