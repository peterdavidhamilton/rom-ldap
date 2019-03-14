RSpec.describe ROM::LDAP::Dataset::Conversion do

  include_context 'animals'

  subject(:dataset) { animals.dataset }

  it '#to_filter' do
    expect(dataset.to_filter).to be_a(String)
    expect(dataset.to_filter).to eql('(species=*)')

    expect {
      ROM::LDAP::Types::Filter[dataset.to_filter]
    }.to_not raise_error

    expect {
      dataset.with(name: '[cn=*]').to_filter
    }.to raise_error(Dry::Types::ConstraintError)
  end

  it '#to_ast' do
    expect(dataset.to_ast).to be_a(Array)
    expect(dataset.to_ast).to eql(%i[op_eql species wildcard])
  end
end
