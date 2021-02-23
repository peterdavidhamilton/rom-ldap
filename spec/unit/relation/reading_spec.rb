RSpec.describe ROM::LDAP::Relation, 'reading' do

  include_context 'people'

  before do
    10.times { factories[:person, :sequence] }
  end

  subject(:relation) { people.with(auto_struct: true).order(:uid_number) }


  with_vendors do

    it '#search' do
      expect(relation.search('(uid=user7)').first[:uid]).to eql(%w'user7')
    end


    it '#reverse' do
      expect(relation.reverse.to_a.map(&:uid)).to eql(
        [
          ['user10'], ['user9'], ['user8'], ['user7'], ['user6'],
          ['user5'], ['user4'], ['user3'], ['user2'], ['user1']
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
          ['user1'], ['user2'], ['user3'], ['user4'], ['user5'],
          ['user6'], ['user7'], ['user8'], ['user9'], ['user10']
        ]
      )
    end


    it '#limit' do
      expect(relation.limit(3).to_a.map(&:uid)).to eql(
        [ ['user1'], ['user2'], ['user3'] ]
      )
    end

    it '#first' do
      expect(relation.first[:uid]).to eql(%w'user1')
    end

    it '#last' do
      expect(relation.last[:uid]).to eql(%w'user10')
    end

    it '#map' do
      expect(relation.map(:uid)).to be_a(Enumerator)

      expect(relation.limit(4).map(:uid).to_a).to eql(
        [['user1'], ['user2'], ['user3'], ['user4'] ]
      )
    end

    it '#unique?' do
      expect(relation.where(uid: 'user3').unique?).to be(true)
      expect(relation.where(uid: 'user3').one?).to be(true)
      expect(relation.where(uid: 'user3').distinct?).to be(true)
    end

    it '#any?' do
      expect(relation.any? { |a| a[:uid] == %w'user1' }).to be(true)
      expect(relation.exist? { |a| a[:uid] == %w'foo' }).to be(false)
    end

    it '#none?' do
      expect(relation.none? { |a| a[:uid] == %w'foo' }).to be(true)
    end

    it '#all?' do
      expect(relation.all? { |a| !a[:uid].nil? }).to be(true)
    end

    it '#count' do
      expect(relation.count).to eql(10)
    end

  end
end
