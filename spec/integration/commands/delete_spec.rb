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
  end

  # describe '#transaction' do
  #   it 'deletes in normal way if no error raised' do
  #     expect {
  #       accounts.transaction do
  #         delete_account.by_uid('test2').call
  #       end
  #     }.to change { accounts.count }.by(-1)
  #   end

  #   it 'deletes nothing if error was raised' do
  #     expect {
  #       accounts.transaction do |t|
  #         delete_account.by_uid('test2').call
  #         t.rollback!
  #       end
  #     }.to_not change { accounts.count }
  #   end
  # end

  # describe '#call' do
  #   it 'deletes all tuples in a restricted relation' do
  #     result = delete_account.by_uid('test1').call

  #     # expect(result).to eql(id: 3, name: 'Jade')
  #     expect(result).to eql(true)
  #   end

  #   it 're-raises database error' do
  #     command = delete_account.by_uid('test1')

  #     # TODO: raise error - currently returns empty dataset array
  #     # expect(command.relation).to receive(:delete).and_raise(
  #     #   Sequel::DatabaseError, 'totally wrong'
  #     # )

  #     expect {
  #       command.call
  #     }.to raise_error(ROM::SQL::DatabaseError, /totally wrong/)
  #   end
  # end

end
