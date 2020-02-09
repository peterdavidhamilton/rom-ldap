require 'rom/transformer'

RSpec.describe ROM::LDAP::Commands::Create do

  # NB: 389DS and OpenLDAP include modify_timestamp when an entry is created.
  with_vendors do

    before do
      conf.relation(:accounts) do
        schema('(objectClass=person)') do
          attribute :uid,              ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::String
          attribute :create_timestamp, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::Time
          attribute :modify_timestamp, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::Time
        end
      end

      class CustomMapper < ROM::Transformer
        relation    :accounts
        register_as :timestamp_mapper

        map do
          rename_keys modify_timestamp: :updated_at,
                      create_timestamp: :created_at
        end
      end

      conf.register_mapper(CustomMapper)
    end

    after do
      relations[:accounts].delete
    end

    context 'without mapper' do

      let(:command) do
        relations[:accounts].command(:create, result: :many)
      end

      it 'attributes are unchanged' do
        entries = command.call(
          [
            {
              dn: 'uid=captain_america,ou=specs,dc=rom,dc=ldap',
              cn: 'Captain America',
              uid: 'captain_america',
              given_name: 'Steve',
              sn: 'Rogers',
              object_class: %w[extensibleobject inetorgperson]
            },
            {
              dn: 'uid=iron_man,ou=specs,dc=rom,dc=ldap',
              cn: 'IronMan',
              uid: 'iron_man',
              given_name: 'Tony',
              sn: 'Stark',
              object_class: %w[extensibleobject inetorgperson]
            }
          ])

        expect(entries).to be_an(Array)

        expect(entries[0][:uid]).to eql('captain_america')
        expect(entries[0]).to have_key(:create_timestamp)
        expect(entries[1][:uid]).to eql('iron_man')
        expect(entries[1]).to have_key(:create_timestamp)
      end


    end


    context 'with mapper' do

      let(:command) do
        relations[:accounts].command(:create, result: :many, mapper: :timestamp_mapper)
      end

      it 'attributes are renamed' do
        time_now = Time.now.utc

        entry, _ = command.call(
            dn: 'uid=black_panther,ou=specs,dc=rom,dc=ldap',
            cn: 'King of Wakanda',
            uid: 'black_panther',
            given_name: "T'Challa",
            sn: 'Udaku',
            object_class: %w[extensibleobject inetorgperson]
          )

        expect(entry).to_not have_key(:dn)
        expect(entry).to_not have_key(:cn)
        expect(entry[:uid]).to eql('black_panther')
        expect(entry[:created_at]).to be_an_instance_of(Time)
        expect(entry[:created_at]).to be_within(1).of(time_now)
      end
    end


  end

end
