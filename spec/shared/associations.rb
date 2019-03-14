require 'rom/memory'

RSpec.shared_context 'associations' do

  include_context 'directory'

  let(:conf) do
    ROM::Configuration.new(
      default: [:ldap, uri, gateway_opts],
      other:   [:memory, 'memory://test'],
    )
  end

  before do

    # directory.add(
    #   dn: "cn=animal,#{base}",
    #   cn: 'animal',
    #   labeled_uri: 'labeled_uri',
    #   species: 'species',
    #   study: 'study',
    #   object_class: %w[extensibleObject mammalia]
    # )

    class Species < ROM::Relation[:ldap]
      # No inference
      schema('(species=*)', as: :species) do
        associations do
          belongs_to :researchers,
            as: :researcher,
            combine_key: :field,
            # combine_keys: { study: :field },
            combine_key: { study: :field },
            view: :biography,
            override: true
        end
      end

      auto_map false

      def by_name(commonname)
        where(cn: commonname)
      end

      def ordered
        order('species')
      end

      def for_researchers(researchers)
        where(study: researchers.map { |tuple| tuple[:field] })
      end

      def with_researcher
        combine(:researchers)
      end
    end


    class Researchers < ROM::Relation[:memory]
      gateway :other

      schema(:researchers, as: :researchers) do
        attribute :id,    ROM::Types::Integer
        attribute :name,  ROM::Types::String
        attribute :field, ROM::Types::String # => study

        primary_key :id

        associations do
          has_many :species,
            combine_key: 'study',
            override: true,
            # combine_keys: { study: :field }
            view: :ordered
        end
      end

      auto_map false

      def for_animals(animals)
        restrict(field: animals.list('study').first)
      end

      def biography
        project(:name)
      end
    end

    conf.register_relation(Researchers)
    conf.register_relation(Species)
  end

  let(:researchers) { container.relations[:researchers] }
  let(:species)     { container.relations[:species] }
end
