#
# A relation will initially use the search base defined in the gateway.
#
# The search base can be inspected using the #base method
#
# The search base can be changed using the #with_base, #whole_tree and #branch methods.
#
RSpec.describe ROM::LDAP::Relation, 'search base' do

  include_context 'directory'

  before do
    conf.relation(:foo) do
      schema('(objectClass=*)', infer: true)
      base 'ou=department,dc=example,dc=com'
      branches finance: 'ou=finance,dc=example,dc=com'
    end
  end

  let(:relation) { relations.foo }

  it '#base defaults to the gateway search base' do
    expect(relation.base).to eql(gateway_opts[:base])
    expect(relation.base).to_not eql(relation.class.base)
  end

  it '#base is unaffected by chained queries' do
    expect(relation.where(cn: '*').base).to eql(relation.base)
  end

  it '#with_base changes to a given search base or class base' do
    expect(relation.class.base).to eql('ou=department,dc=example,dc=com')
    expect(relation.with_base.base).to eql('ou=department,dc=example,dc=com')

    expect(relation.with_base('ou=marketing,dc=example,dc=com').base).to eql('ou=marketing,dc=example,dc=com')
  end

  it '#whole_tree widens search base to the whole directory' do
    expect(relation.whole_tree.base).to eql("")
  end

  it '#branch changes to a named search base branch' do
    expect(relation.branch(:finance).base).to eql('ou=finance,dc=example,dc=com')
  end


  context 'when gateway does not set base' do
    let(:base) { nil}

    it '#base defaults to the whole tree' do
      expect(relation.base).to eql("")
    end
  end



  # it '#primary_key' do
  # end

  # it '#project' do
  # end

  # it '#exclude' do
  # end

  # it '#rename' do
  # end

  # it '#prefix' do
  # end

  # it '#wrap' do
  # end

end
