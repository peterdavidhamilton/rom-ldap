require 'rom/memory'

RSpec.shared_context 'associations' do

  include_context 'directory'

  let(:conf) do
    ROM::Configuration.new(
      default: [:ldap, server],
      other:   [:memory, 'memory://test'],
    )
  end

  before do
    class Predators < ROM::Relation[:ldap]
      schema('(species=*)', as: :predators, infer: true) do
        attribute 'entryDN', Types::String.meta(foreign_key: true, relation: :countries)

        # associations do
        #   has_many :prey
        #   belongs_to :country
        # end
      end
      base 'ou=animals,dc=example,dc=com'
      auto_map false

      def by_name(name)
        where(cn: name)
      end
    end


    class Prey < ROM::Relation[:ldap]
      schema('(species=*)', as: :prey, infer: true) do
        attribute 'entryDN', Types::String.meta(foreign_key: true, relation: :countries)

        associations do
          # belongs_to :market_data, foreign_key: :symbol, view: :capitalization, override: true
          belongs_to :country, foreign_key: :dn, override: true
          # has_one :country
          has_many :predators
        end
      end

      # relation.base.to_a # narrows base from one defined in cofig to one defined on relation class.
      base 'ou=animals,dc=example,dc=com'
      # FIXME: works once then filter becomes empty string
      # dataset { present(:species) }
      auto_map false

      def for_predators(predators)
        # where(cn: predators.map { |tuple| tuple[:cn] })
        where(dn: predators.map(&:dn))
      end

      def with_country
        # combine(:country)
        combine(countries)
        # combine_with(countries)
      end
    end


    class Countries < ROM::Relation[:memory]
      gateway :other
      schema do
        attribute :dn,   Types::String #.meta(foreign_key: true, relation: :prey)
        attribute :name, Types::String #.meta(primary_key: true)

        associations do
          has_many :predators, combine_key: :dn
          # has_many :predators, foreign_key: :dn
          has_many :prey, foreign_key: :dn
        end
      end

      # tuples might have string keys - always have dn method
      def with_wildlife(animals)
        # restrict(dn: animals.map { |u| u[:dn] })
        restrict(dn: animals.map(&:dn))
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
