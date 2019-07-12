# RSpec.describe ROM::LDAP::Relation do

#   include_context 'factory'

#   before do
#     conf.relation(:marketing) do
#       schema('(ou=*)') do
#         attribute :ou,
#           ROM::LDAP::Types::String, read: ROM::LDAP::Types::String
#         attribute :object_class,
#           ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::Symbols
#         # attribute :entry_parent_id,
#         #   ROM::LDAP::Types::String, read: ROM::LDAP::Types::String
#         # attribute :entry_dn,
#         #   ROM::LDAP::Types::String, read: ROM::LDAP::Types::String
#         # attribute :entry_uuid,
#         #   ROM::LDAP::Types::String, read: ROM::LDAP::Types::String

#         # use :timestamps,
#         #   attributes: %i(create_timestamp modify_timestamp),
#         #   type: ROM::LDAP::Types::Time

#       end


#       view(:by_unit, %i[ou entry_uuid entry_parent_id]) do |ou|
#         where(ou: ou)
#       end

#       view(:by_parent, %i[entry_dn entry_parent_id]) do |uuid|
#         where(entry_parent_id: uuid)
#       end

#       view(:hidden_2) do
#         # schema { append(relations[:tasks][:title]) }
#         schema { project(:entry_uuid) }
#         # schema { self }
#         # relation { operational }
#       end


#       # def parent
#       #   binding.pry
#       #   id = operational.first[:entry_parent_id].first

#       #   where(marketing[:entry_uuid].is(id))
#       # end

#       # view(:hidden_3, schema.project(:entry_dn, :entry_uuid, :create_timestamp)) do
#       #   order(:create_timestamp)
#       # end
#     end
#   end

#   subject(:relation) { relations[:marketing] }


#   xit 'defines views' do

#   end
# end



RSpec.describe 'Overview' do

  include_context 'dragons'

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
