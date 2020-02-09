RSpec.describe ROM::LDAP::Relation, 'cover' do

  include_context 'people'

  # 1 - 4 - 9 - 16
  before do
    4.times { |i| factories[:person, uid_number: (i+1)**2] }
  end

  let(:people) { relations[:people].order(:uid_number) }


  with_vendors do

    describe '#within' do
      let(:relation) { people.within(uidnumber: 3..9) }

      it 'is inside the upper and lower bound (inclusive)' do
        expect(relation.count).to eql(2)
        expect(relation.map(:uid_number).to_a.flatten).to eql(%w[4 9])
      end
    end


    describe '#between (within)' do
      let(:relation) { people.between(uid_number: -1..12) }

      it 'is inside the upper and lower bound' do
        expect(relation.count).to eql(3)
        expect(relation.map(:uid_number).to_a.flatten).to eql(%w[1 4 9])
      end
    end


    describe '#outside' do
      let(:relation) { people.outside(uidnumber: 30..100) }

      it 'is outside the upper and lower bound' do
        # expect(1..4).to cover(2)
        expect(relation.count).to eql(4)
        expect(relation.map(:uid_number).to_a.flatten).to eql(%w[1 4 9 16])
      end
    end

  end

end
