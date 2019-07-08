RSpec.describe ROM::LDAP::Dataset do

  include_context 'factory'

  before do
    conf.relation(:foo) { schema('(cn=*)', infer: true) }
  end

  subject(:dataset) { relations.foo.dataset }

  it 'acts like an enumerator' do
    expect(dataset).to respond_to(:each)
    expect(dataset).to respond_to(:to_a)
  end


  it '#unfiltered' do
    expect(dataset.present(:foo).unfiltered.opts[:criteria]).to eql([])
  end

  it '#grep' do
    expect(dataset.grep(%i'givenname sn', 'foo').opts[:criteria]).to eql([
      :con_or, [[:op_eql, :givenname, '*foo*'], [:op_eql, :sn, '*foo*']]
    ])
  end

  it 'reveals internal options' do
    expect(dataset.opts).to have_key(:name)
    expect(dataset.opts).to have_key(:base)
    expect(dataset.opts).to have_key(:criteria)
    expect(dataset.opts).to have_key(:filter)
    expect(dataset.opts).to have_key(:ast)
    expect(dataset.opts).to have_key(:limit)
    expect(dataset.opts).to have_key(:offset)
    expect(dataset.opts).to have_key(:attrs)
    expect(dataset.opts).to have_key(:sort_attrs)
    expect(dataset.opts).to have_key(:directory)
  end


  # xit '#with' do
  # end

  # xit 'init' do
  #   Class.new(ROM::LDAP::Dataset) do
  #   end
  # end

end
