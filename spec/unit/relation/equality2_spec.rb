# FIXME: server-side sorting will allow #order to be called anywhere not just last
# subject(:relation) do
#   animals
#     .project(:population_count)
#     .gte(population_count: 300)
#     .order(:population_count)
#     .to_a
# end


# TODO: move to dataset species
#
# it 'AST: [:op_gte, :attr, value]' do
#   expect(relation.query_ast).to eql(
#     [
#       :con_and,
#       [
#         [:op_eql, 'species', :wildcard],
#         [:op_gte, :population_count, 300]
#       ]
#     ]
#   )
# end

# it 'FILTER: (attr >= value)' do
#   expect(relation.source_filter).to eql('(species=*)')
#   expect(relation.ldap_string).to eql(
#     '(&(species=*)(populationCount>=300))'
#   )
# end


# it 'AST: [:op_lte, :attr, value]' do
#   expect(relation.query_ast).to eql(
#     [
#       :con_and,
#       [
#         [:op_eql, 'species', :wildcard],
#         [:op_lte, :population_count, 300]
#       ]
#     ]
#   )
# end

# it 'FILTER: (attr <= value)' do
#   expect(relation.source_filter).to eql('(species=*)')
#   expect(relation.ldap_string).to eql(
#     '(&(species=*)(populationCount<=300))'
#   )
# end


RSpec.describe ROM::LDAP::Relation, 'equality' do

  include_context 'animals'

  before do
    factories[:animal, :rare_bird, population_count: 50]
    factories[:animal, :rare_bird, population_count: 100]
    factories[:animal, :amphibian, population_count: 300]
    factories[:animal, :reptile, population_count: 1_000]
    factories[:animal, :mammal, population_count: 2_000]
  end

  let(:results) do
    animals
      .public_send(method, population_count: value)
      .project(:population_count)
      .order(:population_count)
      .to_a
      .map { |e| e[:population_count] }
  end


  describe '#equal' do

    let(:method) { :equal }
    let(:value) { 50 }

    it 'is equal to' do
      expect(results).to eql([50])
    end
  end


  describe '#unequal' do

    let(:method) { :unequal }
    let(:value) { 50 }

    it 'is not equal to' do
      expect(results).to eql([100, 300, 1_000, 2_000])
    end
  end


  describe '#gte' do

    let(:method) { :gte }
    let(:value) { 300 }

    it 'is greater than or equal to' do
      expect(results).to eql([300, 1_000, 2_000])
    end
  end



  describe '#lte' do

    let(:method) { :lte }
    let(:value) { 300 }

    it 'is less than or equal to' do
      expect(results).to eql([50, 100, 300])
    end
  end

end
