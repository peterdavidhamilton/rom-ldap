require 'spec_helper'

RSpec.describe 'type builder' do

  let(:formatter) { nil }
  include_context 'relations'

  subject(:account) { accounts.to_a.last }

  it 'coerces uidNumber to an integer' do
    expect(account['uidNumber']).to eql(9)
  end

  it 'coerces gidNumber to an integer' do
    expect(account['gidNumber']).to eql(9998)
  end

  it 'coerces time values' do
    # expect(account['dateActivated']).to eql()
  end

  it 'coerces boolean values' do
    # expect(account['activate']).to eql([true])
  end
end
