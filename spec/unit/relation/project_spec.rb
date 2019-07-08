RSpec.describe ROM::Relation, '#project / #select' do

  include_context 'people'

  before do
    10.times.map { 'user' }.each.with_index(1) do |gn, i|
      factories[:person, uid: "#{gn}#{i}", uid_number: i]
    end
  end

  subject(:relation) { people.with(auto_struct: true).order(:uid) }


  it 'arguments' do
    expect(relation.select(:uid).to_a).to include({ uid: %w'user1' })
  end

  it 'block' do
    expect(relation.select { [:uid] }.to_a).to include({ uid: %w'user1' })
  end

  # it do
  #   # expect(
  #     # can only select by the formatted version i.e. snake_case
  #     # relation.select { [ uidnumber, uid_number.as(:value), cn.aliased(:label) ] }
  #     relation.select { [ uid_number.aliased(:value), cn.aliased(:label) ] }.to_a
  #     # ).to include({})
  # end


  it '#select_append' do
    expect(relation.select(:uid).select_append(:uid_number).to_a.first).to be_a(ROM::Struct::Person)

    expect(relation.select(:uid).select_append(:uid_number).to_a.first.to_h).to include({
      uid: ['user1'],
      uid_number: 1
    })

    expect(relation.select(:uid).select_append(:uid_number).first.to_h).to include({
      uid: ['user1'],
      uid_number: ['1']
    })

  end

end

