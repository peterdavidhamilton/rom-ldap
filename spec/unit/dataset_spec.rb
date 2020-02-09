RSpec.describe ROM::LDAP::Dataset do

  include_context 'factory'

  before do
    conf.relation(:asgardians) { schema('(cn=*)', infer: true) }
  end

  subject(:dataset) { relations.asgardians.dataset }

  it 'acts like an enumerator' do
    expect(dataset).to respond_to(:each)
    expect(dataset).to respond_to(:to_a)
  end

  it 'reveals internal options' do
    expect(dataset.opts.keys.size).to eql(13)

    expect(dataset.opts).to have_key(:ast)
    expect(dataset.opts).to have_key(:attrs)
    expect(dataset.opts).to have_key(:aliases)
    expect(dataset.opts).to have_key(:base)
    expect(dataset.opts).to have_key(:criteria)
    expect(dataset.opts).to have_key(:direction)
    expect(dataset.opts).to have_key(:directory)
    expect(dataset.opts).to have_key(:filter)
    expect(dataset.opts).to have_key(:limit)
    expect(dataset.opts).to have_key(:name)
    expect(dataset.opts).to have_key(:offset)
    expect(dataset.opts).to have_key(:random)
    expect(dataset.opts).to have_key(:sort_attrs)
  end

  it '#with overrides options' do
    expect(dataset.with(random: true).opts[:random]).to be(true)
    expect(dataset.with(attrs: %w[foo bar]).opts[:attrs]).to eql(%w[foo bar])
  end


  it '#grep builds an OR query' do
    criteria = dataset.grep(%i'givenname sn', 'odin').opts[:criteria]

    expect(criteria).to eql([
      :con_or, [[:op_eql, :givenname, '*odin*'], [:op_eql, :sn, '*odin*']]
    ])
  end
end
