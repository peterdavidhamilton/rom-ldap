# require 'rom/transformer'

RSpec.shared_context 'auto associations' do |vendor|

  include_context 'factory'

  before do
    conf.relation(:buildings) do
      schema('(ou=building*)') do
        attribute :dn, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::String
        attribute :building_name, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::String
        attribute :ou, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::String
        attribute :object_class, ROM::LDAP::Types::Strings

        associations do
          has_many :rooms, foreign_key: :building_name, view: :has_rooms
        end

        primary_key :building_name
      end

      def has_rooms
        order(:building_name)
      end
    end

    conf.relation(:rooms) do
      schema('(ou=room*)') do
        attribute :dn, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::String
        attribute :ou, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::String
        attribute :room_number, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::Integer
        attribute :building_name, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::String
        attribute :object_class, ROM::LDAP::Types::Strings

        associations do
          has_one :building, foreign_key: :building_name
          has_many :users, as: :occupants, foreign_key: :room_number
        end

        primary_key :room_number
      end
    end

    conf.relation(:users) do
      schema('(objectClass=inetOrgPerson)') do
        attribute :dn, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::String
        attribute :employee_number, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::Integer.meta(primary_key: true)
        attribute :cn, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::Strings
        attribute :sn, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::String
        attribute :room_number, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::Integer
        attribute :object_class, ROM::LDAP::Types::Strings

        associations do
          has_one :room, foreign_key: :room_number
        end
      end
    end



    # class BuildingMapper < ROM::Transformer
    #   relation    :buildings
    #   register_as :building_mapper

    #   map_array do
    #     map_values -> v {
    #       binding.pry
    #       v.is_a?(Array) ? v.pop : v
    #     }
    #   end
    # end


    # conf.register_mapper(BuildingMapper)


    factories.define(:user) do |f|
      f.sequence(:employee_number) { |n| n }
      f.sequence(:cn) { |employee_number| "User #{employee_number}" }
      f.dn { |cn| "cn=#{cn}, ou=specs, dc=rom, dc=ldap" }
      f.sn { fake(:name, :last_name) }
      f.room_number { fake(:number, :digit) }
      f.object_class %w[
        inetOrgPerson
        extensibleObject
      ]
    end

    factories.define(:room) do |f|
      f.sequence(:room_number) { |n| n }
      f.sequence(:ou) { |room_number| "Room #{room_number}" }
      f.dn { |ou| "ou=#{ou}, ou=specs, dc=rom, dc=ldap" }
      f.building_name 'Building 1'
      f.object_class %w[
        organizationalUnit
        extensibleObject
      ]
      # f.association :users, count: 30
    end

    factories.define(:building) do |f|
      f.sequence(:ou) { |n| "Building #{n}" }
      f.building_name { |ou| ou }
      f.dn { |ou| "ou=#{ou}, ou=specs, dc=rom, dc=ldap" }
      f.object_class %w[
        organizationalUnit
        extensibleObject
      ]
      # f.association :rooms, count: 10
    end
  end


  let(:users) { relations[:users] }
  let(:rooms) { relations[:rooms] }
  let(:buildings) { relations[:buildings] }

  after do
    users.delete
    rooms.delete
    buildings.delete
  end

end
