RSpec.describe ROM::LDAP::Parsers::Base do

  let(:parser) { ROM::LDAP::Parsers::Base.new(schemas: []) }

  it 'uses default constructors' do
    expect(parser.constructors).to eql({
      :con_and => "&",
      :con_not => "!",
      :con_or  => "|"
    })
  end

  it 'uses default operators' do
    expect(parser.operators).to eql({
      :op_eql => "=",
      :op_ext => ":=",
      :op_gte => ">=",
      :op_lte => "<=",
      :op_prx => "~="
    })
  end

  it 'uses default values' do
    expect(parser.values).to eql({
      :wildcard => "*",
      true => "TRUE",
      false => "FALSE"
    })
  end

  it 'requires #call to be implemented' do
    expect { parser.call }.to raise_error(NotImplementedError)
  end
end
