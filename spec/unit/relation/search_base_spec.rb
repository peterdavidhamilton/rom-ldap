RSpec.describe ROM::LDAP::Relation, 'search base' do

  include_context 'directory'

  before do
    conf.relation(:foo) do
      schema('(objectClass=*)', infer: true)
      base 'ou=department,dc=rom,dc=ldap'
      branches finance: 'ou=finance,dc=rom,dc=ldap'
    end
  end

  let(:relation) { relations.foo }

  it '#base can be overridden by the relation class' do
    expect(relation.base).to_not eql(gateway_opts[:base])
    expect(relation.base).to eql(relation.class.base)
  end

  it '#base is unaffected by chained queries' do
    expect(relation.where(cn: '*').base).to eql(relation.base)
  end

  it '#with_base changes to a given search base or class base' do
    expect(relation.base).to eql('ou=department,dc=rom,dc=ldap')
    expect(relation.with_base('ou=marketing,dc=rom,dc=ldap').base).to eql('ou=marketing,dc=rom,dc=ldap')
  end

  it '#whole_tree widens search base to the whole directory' do
    expect(relation.whole_tree.base).to eql("")
  end

  it '#branch changes to a named search base branch' do
    expect(relation.branch(:finance).base).to eql('ou=finance,dc=rom,dc=ldap')
  end


  context 'when gateway does not set base' do
    let(:base) { nil }

    before do
      conf.relation(:foo) do
        schema('(objectClass=*)', infer: true)
      end
    end

    it '#base defaults to the whole tree' do
      expect(relation.base).to eql("")
    end
  end

end
