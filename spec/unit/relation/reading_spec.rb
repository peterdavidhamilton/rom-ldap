RSpec.describe ROM::LDAP::Relation, 'reading' do

  include_context 'people'

  before do
    10.times.map { 'user' }.each.with_index(1) do |gn, i|
      factories[:person, uid: "#{gn}#{i}"]
    end
  end

  subject(:relation) { people.with(auto_struct: true).order(:uid) }


  it '#search' do
    expect(relation.search('(uid=user7)').first[:uid]).to eql(['user7'])
  end


  it '#reverse' do
    expect(relation.reverse.to_a.map(&:uid)).to eql(
      [
        ['user9'], ['user8'], ['user7'], ['user6'], ['user5'],
        ['user4'], ['user3'], ['user2'], ['user10'], ['user1']
      ]
    )
  end


  it '#unfiltered' do
    expect(relation.where(uid: 'user10').count).to eql(1)
    expect(relation.where(uid: 'user10').unfiltered.count).to eql(10)
  end


  it '#random' do
    expect(relation.random.to_a.map(&:uid)).not_to eql(
      [
        ['user1'], ['user10'], ['user2'], ['user3'], ['user4'],
        ['user5'], ['user6'], ['user7'], ['user8'], ['user9']
      ]
    )
  end


  it '#limit' do
    expect(relation.limit(3).to_a.map(&:uid)).to eql(
      [ ['user1'], ['user10'], ['user2']]
    )
  end

  it '#first' do
    expect(relation.first[:uid]).to eql(['user1'])
  end

  it '#last' do
    expect(relation.last[:uid]).to eql(['user9'])
  end

  it '#map' do
    expect(relation.map(:uid)).to be_a(Enumerator)

    expect(relation.limit(4).map(:uid).to_a).to eql(
      [['user1'], ['user10'], ['user2'], ['user3'] ]
    )
  end

  it '#unique?' do
    expect(relation.where(uid: 'user3').unique?).to eql(true)
    expect(relation.where(uid: 'user3').one?).to eql(true)
    expect(relation.where(uid: 'user3').distinct?).to eql(true)
  end

  it '#any?' do
    expect(relation.any? { |a| a[:uid] == %w'user1' }).to eql(true)
    expect(relation.exist? { |a| a[:uid] == ['foo'] }).to eql(false)
  end

  it '#none?' do
    expect(relation.none? { |a| a[:uid] == ['foo'] }).to eql(true)
  end

  it '#all?' do
    expect(relation.all? { |a| !a[:uid].nil? }).to eql(true)
  end

  it '#count' do
    expect(relation.count).to eql(10)
  end

end
