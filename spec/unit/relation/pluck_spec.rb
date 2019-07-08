RSpec.describe ROM::LDAP::Relation, '#pluck' do

  include_context 'people'

  before do
    10.times.map { 'user' }.each.with_index(1) do |gn, i|
      factories[:person, uid: "#{gn}#{i}", cn: "#{gn}#{i}".upcase]
    end
  end

  subject(:relation) { people.with(auto_struct: true).order(:uid) }


  it 'providing no keys returns empty array' do
    expect(relation.pluck.first).to be_empty
  end

  it 'when the keys have a single value' do
    expect(relation.pluck(:uid)).to be_an(Array)
    expect(relation.pluck(:uid).first).to be_a(String)
    expect(relation.pluck(:uid).first).to eql('user1')
  end

  it 'when the keys have multiple values' do
    expect(relation.pluck(:uid, :cn)).to be_an(Array)
    expect(relation.pluck(:uid, :cn).first).to be_a(Array)

    # return in alphabetical order cn then uid
    expect(relation.pluck(:uid, :cn).first).to eql(['USER1', 'user1'])
  end

end
