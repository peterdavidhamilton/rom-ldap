RSpec.describe ROM::LDAP::Relation, 'matching' do

  include_context 'people'

  before do
    %w[rita sue bob].each do |gn|
      factories[:person, uid: gn, mail: "#{gn}@example.com"]
    end
  end

  subject(:relation) { people.with(auto_struct: true) }


  it '#begins' do
    expect(relation.begins(uid: 'b').one.mail).to eql(%w'bob@example.com')
  end

  it '#ends' do
    expect(relation.ends(uid: 'a').one.mail).to eql(%w'rita@example.com')
  end

  it '#contains' do
    expect(relation.contains(uid: 'o').one.mail).to eql(%w'bob@example.com')
  end

  it '#excludes' do
    expect(relation.excludes(uid: 'i').count).to eql(2)
  end

end
