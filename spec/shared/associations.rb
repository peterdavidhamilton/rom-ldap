require 'rom/memory'

RSpec.shared_context 'associations' do |vendor|

  include_context 'directory'

  let(:conf) do
    TestConfiguration.new(
      default: [:ldap, uri, gateway_opts],
      other:   [:memory, 'memory://test'],
    )
  end

  before do

    class Researchers < ROM::Relation[:memory]
      gateway :other

      schema(:researchers, as: :researchers) do
        attribute :id,    ROM::Types::Integer
        attribute :name,  ROM::Types::String
        attribute :field, ROM::Types::String

        primary_key :id

        associations do
          has_many :organisms, override: true, view: :for_researchers
        end
      end

      # @param organisms [ROM::Relation::Loaded]
      #
      def for_organisms(_assoc, organisms)
        restrict(field: organisms.map { |e| e[:study] }.flatten.uniq)
      end
    end



    class Organisms < ROM::Relation[:ldap]
      schema('(species=*)', as: :organisms, infer: true) do
        associations do
          has_many :researchers, override: true, view: :for_organisms
        end
      end

      def by_name(cn)
        where(cn: cn)
      end

      def for_researchers(_assoc, researchers)
        where(study: researchers.map { |r| r[:field] })
      end
    end


    conf.register_relation(Researchers, Organisms)
  end

  let(:researchers) { container.relations[:researchers] }
  let(:organisms)   { container.relations[:organisms] }

  after do
    organisms.delete
  end
end
