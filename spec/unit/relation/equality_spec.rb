RSpec.describe ROM::LDAP::Relation, 'equality' do

  include_context 'animals'

  with_vendors do

    before do
      factories[:animal, :rare_bird, population_count: 50]
      factories[:animal, :rare_bird, population_count: 100]
      factories[:animal, :amphibian, population_count: 300]
      factories[:animal, :reptile, population_count: 1_000]
      factories[:animal, :mammal, population_count: 2_000]
    end

    let(:results) do
      animals
        .public_send(method, population_count: value)
        .project(:population_count)
        .order(:population_count)
        .to_a
        .map { |e| e[:population_count] }
    end


    describe '#equal' do

      let(:method) { :equal }
      let(:value) { 50 }

      it 'is equal to' do
        expect(results).to eql([50])
      end
    end


    describe '#unequal' do

      let(:method) { :unequal }
      let(:value) { 50 }

      it 'is not equal to' do
        expect(results).to eql([100, 300, 1_000, 2_000])
      end
    end


    describe '#gte' do

      let(:method) { :gte }
      let(:value) { 300 }

      it 'is greater than or equal to' do
        expect(results).to eql([300, 1_000, 2_000])
      end
    end



    describe '#lte' do

      let(:method) { :lte }
      let(:value) { 300 }

      it 'is less than or equal to' do
        expect(results).to eql([50, 100, 300])
      end
    end

  end
end
