RSpec.describe ROM::LDAP::Dataset do

  include_context 'factory'

  before do
    conf.relation(:foo) { schema('cn=*)') }
  end

  subject(:dataset) { relations.foo.dataset }

  it 'acts like an enumerator' do
    expect(dataset).to respond_to(:each)
    expect(dataset).to respond_to(:to_a)
  end

  xit '#with' do
  end

  xit 'init' do
    Class.new(ROM::LDAP::Dataset) do
    end
  end

  it 'reveals internal options' do
    expect(dataset.opts).to have_key(:base)
    expect(dataset.opts).to have_key(:criteria)
    expect(dataset.opts).to have_key(:entries)
    expect(dataset.opts).to have_key(:filter)
    expect(dataset.opts).to have_key(:ldap_string)
    expect(dataset.opts).to have_key(:limit)
    expect(dataset.opts).to have_key(:offset)
    expect(dataset.opts).to have_key(:query_ast)
    expect(dataset.opts).to have_key(:sort_attr)
  end

end
