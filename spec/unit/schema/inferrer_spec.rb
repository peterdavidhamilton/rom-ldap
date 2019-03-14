RSpec.describe ROM::LDAP::Schema::Inferrer do

  include_context 'animals'

  it "has loaded the directory's schema" do
    expect(animals.dataset.directory.attribute_types).to_not be_empty
  end

  it 'has formatted attribute names' do
    expect(animals.schema.to_h.keys).to include(
      *%i[
        cn
        description
        discovery_date
        dn
        endangered
        extinct
        family
        genus
        labeled_uri
        object_class
        order
        population_count
        species
        study
      ]
    )
  end

  it 'has inferred attribute types' do
    primitives = animals.schema.to_h.values.map { |v| v.type.primitive.name }.uniq.sort
    expect(primitives).to eql(['Integer', 'String', 'Time', 'TrueClass | FalseClass'])
  end
end
