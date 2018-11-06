RSpec.shared_context 'dragons' do

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

  let(:dragons) { animals.where(species: 'dragon') }

  after do
    dragons.delete
  end

end
