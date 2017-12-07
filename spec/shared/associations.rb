require 'rom/memory'

RSpec.shared_context 'associations' do

  include_context 'directory'

  let(:conf) do
    ROM::Configuration.new(
      default: [:ldap, server, ldap_options],
      other:   [:memory, 'memory://test'],
    )
  end

  before do
    class Predators < ROM::Relation[:ldap]
      schema('(species=*)', as: :predators, infer: true) do
        attribute 'entryDN',
          Types::String.meta(primary_key: true, foreign_key: true, relation: :countries),
          read: ROM::LDAP::Types::Single::String

        associations do
          has_many :prey
          belongs_to :country
        end
      end

      auto_map false

      def by_name(name)
        where(cn: name)
      end
    end


    class Prey < ROM::Relation[:ldap]
      # schema do
      schema('(species=*)', as: :prey, infer: true) do
        attribute 'entryDN',
          Types::String.meta(primary_key: true, foreign_key: true, relation: :countries),
          read: ROM::LDAP::Types::Single::String

        associations do
          belongs_to :country
          # has_one :country
          has_many :predators
        end
      end
      # FIXME: works once then filter becomes empty string
      # dataset { present(:species) }
      auto_map false

      def for_predators(predators)
        where(cn: predators.map { |tuple| tuple[:cn] })
      end

      def with_country
        combine(:country)
      end
    end


    class Countries < ROM::Relation[:memory]
      gateway :other
      schema do
        attribute :dn,   Types::String #.meta(foreign_key: true, relation: :prey)
        attribute :name, Types::String #.meta(primary_key: true)

        associations do
          has_many :predators, foreign_key: :dn
          has_many :prey, foreign_key: :dn
        end
      end
    end

    conf.register_relation(Countries)
    conf.register_relation(Prey)
    conf.register_relation(Predators)
  end

  let(:countries) { container.relations[:countries] }
  let(:predators) { container.relations[:predators] }
  let(:prey)      { container.relations[:prey] }

end
