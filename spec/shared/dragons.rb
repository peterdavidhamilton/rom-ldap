RSpec.shared_context 'dragons' do

  # Define a new relation
  #
  before do
    conf.relation(:dragons) do
      schema('(species=dragon)', infer: true) do
        # attribute :dn,
        #   ROM::LDAP::Types::String,
        #   read: ROM::LDAP::Types::String

        attribute :cn,
          ROM::LDAP::Types::Strings

        attribute :species,
          ROM::LDAP::Types::String,
          read: ROM::LDAP::Types::String

        attribute :description,
          ROM::LDAP::Types::String,
          read: ROM::LDAP::Types::String

        attribute :population_count,
          ROM::LDAP::Types::Integer,
          read: ROM::LDAP::Types::Integer

        attribute :extinct,
          ROM::LDAP::Types::Bool,
          read: ROM::LDAP::Types::Bool

        attribute :endangered,
          ROM::LDAP::Types::Bool,
          read: ROM::LDAP::Types::Bool

        attribute :discovery_date,
          ROM::LDAP::Types::Time,
          read: ROM::LDAP::Types::Time
      end

      use :pagination
      per_page 13
    end
  end

  include_context 'animals'

  before do
    factories[:animal, :reptile,
              cn: ['Falkor', 'Luck Dragon'],
              species: 'dragon',
              extinct: true,
              endangered: false,
              population_count: 0,
              description: 'Character from The Neverending Story'
    ]
  end

  let(:dragons) { relations[:dragons] }

  after do
    dragons.delete
  end

end
