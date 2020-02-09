RSpec.describe ROM::LDAP::Relation, 'reading' do

  include_context 'people'

  before do
    10.times { factories[:person, :sequence] }
  end

  subject(:relation) { people.with(auto_struct: true).order(:uid) }

  # NB:
  #   only OpenLDAP orders as user1,user2...user9,user10
  #   others order as user1,user10...user8,user9
  #
  with_vendors do

    it '#search' do
      expect(relation.search('(uid=user7)').first[:uid]).to eql(['user7'])
    end


    it '#reverse' do
      expect(relation.reverse.to_a.map(&:uid)).to eql(
        case vendor
        when 'open_ldap'
          [
            ['user10'], ['user9'], ['user8'], ['user7'], ['user6'],
            ['user5'], ['user4'], ['user3'], ['user2'], ['user1']
          ]
        else
          [
            ['user9'], ['user8'], ['user7'], ['user6'], ['user5'],
            ['user4'], ['user3'], ['user2'], ['user10'], ['user1']
          ]
        end

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
        case vendor
        when 'open_ldap'
          [ ['user1'], ['user2'], ['user3']]
        else
          [ ['user1'], ['user10'], ['user2']]
        end
      )
    end

    it '#first' do
      expect(relation.first[:uid]).to eql(['user1'])
    end

    it '#last' do
      expect(relation.last[:uid]).to eql(
        case vendor
        when 'open_ldap'
          ['user10']
        else
          ['user9']
        end
      )
    end

    it '#map' do
      expect(relation.map(:uid)).to be_a(Enumerator)

      expect(relation.limit(4).map(:uid).to_a).to eql(
        case vendor
        when 'open_ldap'
          [['user1'], ['user2'], ['user3'], ['user4'] ]
        else
          [['user1'], ['user10'], ['user2'], ['user3'] ]
        end
      )
    end

    it '#unique?' do
      expect(relation.where(uid: 'user3').unique?).to be(true)
      expect(relation.where(uid: 'user3').one?).to be(true)
      expect(relation.where(uid: 'user3').distinct?).to be(true)
    end

    it '#any?' do
      expect(relation.any? { |a| a[:uid] == %w'user1' }).to be(true)
      expect(relation.exist? { |a| a[:uid] == ['foo'] }).to be(false)
    end

    it '#none?' do
      expect(relation.none? { |a| a[:uid] == ['foo'] }).to be(true)
    end

    it '#all?' do
      expect(relation.all? { |a| !a[:uid].nil? }).to be(true)
    end

    it '#count' do
      expect(relation.count).to eql(10)
    end

  end
end
