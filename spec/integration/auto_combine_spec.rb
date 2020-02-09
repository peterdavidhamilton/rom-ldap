RSpec.xdescribe ROM::LDAP::Relation, '#combine' do

  include_context 'auto associations'

  before do
    factories[:building, building_name: 'Annex']
    3.times.map { factories[:room, building_name: 'Annex'] }
    factories[:user, room_number: 1]
  end

  with_vendors 'open_dj' do
    it 'association joins' do
      # ROM::MapperMisconfiguredError:
      #   [[:dn], [:ou], [:object_class], [:room_number]]
      #   attribute: block is required for :from with union value.
      #
      # buildings.combine(:rooms).to_a

      expect {
        rooms.combine(:buildings).to_a
      }.to_not raise_error(ROM::MapperMisconfiguredError)
    end
  end

end
