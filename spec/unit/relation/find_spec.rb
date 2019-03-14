RSpec.describe ROM::LDAP::Relation, '#find' do

  include_context 'animals'

  before do
    factories[:animal, :mammal, cn: 'Regal Badger']
    factories[:animal, :reptile, family: 'Eganthus']
    factories[:animal, :bird, order: 'Potegantue']
    factories[:animal, :bird, genus: 'egas']
  end

  let(:var) { 'ega' }

  describe 'retrieves a match against all attributes' do
    it do

      expect(animals.project(:description, :genus).find(var).dataset.opts[:filter]).to eql(
        "(&(species=*)(|(description=*ega*)(genus=*ega*)))"
      )

      expect(animals.project(:cn).find(var).count).to eql(1)
      expect(animals.project(:family).find(var).count).to eql(1)
      expect(animals.project(:order).find(var).count).to eql(1)
      expect(animals.project(:genus).find(var).count).to eql(1)

      expect(animals.project(:genus, :order).find(var).count).to eql(2)


# binding.pry
      # expect(animals.find(var).count).to eql(4)
      # expect(animals.project(:family, :genus, :order).find(var).count).to eql(3)
    end
  end

end
