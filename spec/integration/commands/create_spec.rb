require 'rom/transformer'

RSpec.describe ROM::LDAP::Commands::Create do

  include_context 'directory'

  before do
    conf.relation(:accounts) do
      schema('(objectClass=person)', infer: true) do
        attribute :uid,              ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::String
        attribute :create_timestamp, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::Time
        attribute :modify_timestamp, ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::Time
      end
    end

    class CustomMapper < ROM::Transformer
      relation    :accounts
      register_as :timestamp_mapper

      map_array do
        rename_keys modify_timestamp: :updated_at,
                    create_timestamp: :created_at
      end
    end

    conf.register_mapper(CustomMapper)

  end

  let(:custom_create) do
    relations[:accounts].command(:create, result: :many, mapper: :timestamp_mapper)
  end

  after do
    relations[:accounts].delete
  end


  it 'create many with mapper' do
    result = custom_create.call(
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

    expect(result).to be_an(Array)

    expect(result[0][:uid]).to eql('captain_america')
    expect(result[1][:uid]).to eql('iron_man')
  end



  it 'create one' do
    result = custom_create.call(
        dn: 'uid=black_panther,ou=specs,dc=rom,dc=ldap',
        cn: 'King of Wakanda',
        uid: 'black_panther',
        given_name: "T'Challa",
        sn: 'Udaku',
        object_class: %w[extensibleobject inetorgperson]
      )

    time_now = Time.now.utc

    expect(result).to be_a(Array)

    # expect(result.first).to_not have_key(:dn)
    # expect(result.first).to_not have_key(:cn)

    expect(result.first).to have_key(:uid)
    expect(result.first[:uid]).to eql('black_panther')

    expect(result.first).to have_key(:created_at)
    expect(result.first[:created_at]).to be_an_instance_of(Time)

    # docker-machine ssh "sudo date -u $(date -u +%m%d%H%M%Y)"
    expect(result.first[:created_at]).to be_within(1).of(time_now)

  end

end
