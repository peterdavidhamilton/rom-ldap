RSpec.describe ROM::LDAP::Relation do

  include_context 'directory'

  before do
    conf.relation(:wildlife) do
      schema('(*)', infer: true)
      base 'ou=department,dc=example,dc=com'
    end
  end

  let(:relation) { relations.wildlife }

  it '#base' do
    expect(relation.current_base).to eql(server[:base])
    expect(relation.class.base).to eql('ou=department,dc=example,dc=com')
    expect(relation.with_base.current_base).to eql('ou=department,dc=example,dc=com')
  end

  it '#primary_key' do
  end

  it '#project' do
  end

  it '#exclude' do
  end

  it '#rename' do
  end

  it '#prefix' do
  end

  it '#wrap' do
  end

end
