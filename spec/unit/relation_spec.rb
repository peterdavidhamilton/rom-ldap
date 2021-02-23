RSpec.describe 'Overview' do

  include_context 'dragons'

  with_vendors do

    describe 'ROM::LDAP::Relation' do

      it 'auto_struct defaults to false' do
        expect(dragons.auto_struct?).to eql(false)
      end

      it '#first returns Hash whose values are Arrays of strings' do
        expect(dragons.first).to be_a(Hash)
        expect(dragons.first[:species]).to eql(%w'dragon')
        expect(dragons.first[:extinct]).to eql(%w'TRUE')
        expect(dragons.first[:population_count]).to eql(%w'0')
      end

      it '#one returns Hash whose values have been coerced' do
        expect(dragons.one).to be_a(Hash)
        expect(dragons.one[:species]).to eql('dragon')
        expect(dragons.one[:extinct]).to be(true)
        expect(dragons.one[:population_count]).to be(0)
      end

      it '#to_a returns an Array of coerced Hashes' do
        expect(dragons.to_a.first).to be_a(Hash)
        expect(dragons.to_a.first[:species]).to eql('dragon')
        expect(dragons.to_a.first[:population_count]).to be(0)
      end


      context 'with auto_struct=true' do
        let(:dragons) { relations.dragons.with(auto_struct: true) }

        it 'it creates structs' do
          expect(dragons.auto_struct?).to eql(true)
          expect(dragons.one).to be_a(ROM::Struct::Dragon)
          expect(dragons.one.description).to be_a(String)
        end

        it 'structs can be renamed or changed' do
          expect(dragons.as(:serpent).one).to be_a(ROM::Struct::Serpent)
          expect(dragons.map_to(::OpenStruct).one).to be_a(::OpenStruct)
        end

        describe 'ROM::Struct' do
          subject { dragons.with(auto_struct: true).one }

          it { is_expected.to have_attributes(species: 'dragon') }
          it { is_expected.to have_attributes(description: a_string_starting_with('Character')) }
          it { is_expected.to have_attributes(extinct: true) }
        end
      end

    end
  end
end
