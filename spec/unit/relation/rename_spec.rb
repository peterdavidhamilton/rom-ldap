RSpec.describe ROM::LDAP::Relation, '#rename' do

  include_context 'people'

  before do
    10.times { factories[:person, :sequence] }
  end

  subject(:relation) do
    people.with(auto_struct: true).order(:uid).rename(uid: :user_id, cn: :display_name)
  end

  it 'aliases in schema' do
    expect(relation.schema.map(&:alias)).to include(:user_id, :display_name)
  end

  # it 'renames entries' do
  #   expect(relation.rename(uid: :user_id).first).to eql({})
  #   expect(relation.rename(cn: :display_name)).to eql({})
  # end

end
