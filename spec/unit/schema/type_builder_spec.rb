require 'spec_helper'

RSpec.describe 'type builder' do

  include_context 'relations'

  let(:account) { accounts.to_a.first }

  it 'coerces integer values' do
    expect(account['uidNumber']).to eql([0])
  end

  it 'coerces time values' do
    # expect(account['dateActivated']).to eql()
  end

  it 'coerces boolean values' do
    # expect(account['activate']).to eql([true])
  end
end
