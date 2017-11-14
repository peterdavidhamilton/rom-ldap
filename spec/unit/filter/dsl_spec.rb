require 'spec_helper'

RSpec.describe 'relation query dsl' do
  include_context 'factories'

  let(:formatter) { old_format_proc }

  describe 'factoried people relation "gidnumber=1"' do
    let(:user_names) { %w[barry billy bobby sally] }

    it '#equals' do
      expect(people.equals(uid: 'billy').count).to eql(1)
      expect(people.where(uid: 'billy').count).to eql(1)
    end

    it '#unequals' do
      expect(people.unequals(uid: 'susan').count).to eql(4)
    end

    it '#present' do
      expect(people.present(:gidnumber).count).to eql(4)
      expect(people.has(:gidnumber).count).to eql(4)
    end

    it '#begins' do
      expect(people.begins(uid: 'b').count).to eql(3)
      expect(people.prefix(uid: 'ba').count).to eql(1)
    end

    it '#ends' do
      expect(people.ends(uid: 'by').count).to eql(1)
      expect(people.suffix(uid: 'by').count).to eql(1)
    end

    it '#contains' do
      expect(people.contains(uid: 'b').count).to eql(3)
      expect(people.matches(mail: '@example.com').count).to eql(4)
    end

    it '#within' do
      results = people.with(auto_struct: false).select(:uid, :uniqueidentifier).to_a
      expect(results).to eql(
        [
          { uid: 'barry', uniqueidentifier: 1  },
          { uid: 'billy', uniqueidentifier: 4  },
          { uid: 'bobby', uniqueidentifier: 9  },
          { uid: 'sally', uniqueidentifier: 16 }
        ]
      )

      # binding.pry
      expect(people.within(uniqueidentifier: 0..12).count).to eql(3)
      expect(people.between(uniqueidentifier: 30..100).count).to eql(0)
      expect(people.range(uniqueidentifier: 3..9).count).to eql(2)
    end

    it '#gte' do
      # binding.pry
      expect(people.gte(uniqueidentifier: 4).count).to eql(3)
      expect(people.above(uniqueidentifier: 5).count).to eql(2)
    end

    it 'lte' do
      # binding.pry
      expect(people.lte(uniqueidentifier: 9).count).to eql(3)
      expect(people.below(uniqueidentifier: 11).count).to eql(3)
    end

    it '#outside' do
      # binding.pry
      results = people.outside(uniqueidentifier: 30..100)

      expect(results.to_a.count).to eql(4)
      expect(results.select(:uniqueidentifier).to_a.map(&:values)).to cover(4)
    end
  end
end
