begin
  require 'rom-sql'
rescue LoadError
end

RSpec.xdescribe 'ROM-SQL Integration' do

  let(:ssl) { false }

  let(:conf) do
    TestConfiguration.new(
      ldap: [:ldap, uri_for('open_ldap'), base: 'ou=specs,dc=rom,dc=ldap', extensions: %i[compatibility]],
      sql:  [:sql, 'sqlite::memory'],
    )
  end

  let(:container) { ROM.container(conf) }

  let(:directory) { conf.gateways[:ldap].directory }

  let(:database) { conf.gateways[:sql].connection }

  before do

    database.create_table :teams  do
      primary_key :id, index: true
      column :name, String, index: true, null: false, unique: true
    end

    conf.relation(:teams, adapter: :sql) do
      gateway :sql
      schema :teams, infer: true do
        associations do
          has_many :staff, as: :members, override: true, view: :affiliation

          # one_to_many :staff, relation: :staff, override: true, view: :affiliation
          # one_to_many :staff, override: true, view: :affiliation
        end
      end

      def memberships(_assoc, staff)
        where(id: staff.map { |t| t[:gid_number] }.flatten.uniq)
      end
    end


    conf.relation(:staff, adapter: :ldap, gateway: :ldap) do
      schema '(objectClass=person)', as: :staff do
        attribute :dn,            ROM::LDAP::Types::Strings,
          read: ROM::LDAP::Types::String
        attribute :uid,           ROM::LDAP::Types::Strings,
          read: ROM::LDAP::Types::String
        attribute :cn,            ROM::LDAP::Types::Strings,
          read: ROM::LDAP::Types::Strings
        attribute :given_name,    ROM::LDAP::Types::Strings,
          read: ROM::LDAP::Types::String
        attribute :sn,            ROM::LDAP::Types::Strings,
          read: ROM::LDAP::Types::String
        attribute :gid_number,    ROM::LDAP::Types::Strings,
          read: ROM::LDAP::Types::Integer
        attribute :object_class,  ROM::LDAP::Types::Strings,
          read: ROM::LDAP::Types::Strings

        associations do
          has_one :team, override: true, view: :memberships

          # not overriding means associations must work with sql relations
          # otherwise :"(objectClass=person)_id"
          # has_one :team, foreign_key: :id
          # has_one :team, join_keys: {gid_number: :id}
        end
      end

      def affiliation(_assoc, teams)
        where(gid_number: teams.map { |r| r[:id] })
      end
    end

  end

  after do
    teams.delete
    staff.delete
  end

  let(:teams) { container.relations[:teams] }
  let(:staff) { container.relations[:staff] }

  it 'config can setup sql and ldap' do
    expect { container }.to_not raise_error
  end


  it 'tuples can be combined' do
    teams.insert(name: 'Anti-Heroes')

    staff.insert(
      dn: 'uid=spawn, ou=specs, dc=rom, dc=ldap',
      uid: 'spawn',
      cn: ['Al Simmons', 'Albert Francis Simmons'],
      given_name: 'Al',
      sn: 'Simmons',
      gid_number: 1,
      object_class: %w{extensibleObject person}
    )

    expect(staff.count).to eql(1)

    expect(teams.count).to eql(1)

    expect(staff.combine(:teams).one).to include(team: {
      id: 1, name: 'Anti-Heroes'
    })

    expect(teams.combine(:staff).to_a).to include(members: [{
      sn: 'Simmons'
    }])
  end

end
