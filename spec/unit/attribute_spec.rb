RSpec.describe ROM::LDAP::Attribute do

  include_context 'animals'

  # https://en.wikipedia.org/wiki/Kakapo
  it '#is (==)' do
    expect(animals[:species].is('Strigops habroptilus')).to eql(
      [:op_eql, :species, 'Strigops habroptilus'])
    expect(animals[:species] == 'Strigops habroptilus').to eql(
      [:op_eql, :species, 'Strigops habroptilus'])
  end

  # https://en.wikipedia.org/wiki/Jaguarundi
  it '#not (!=)' do
    expect(animals[:species].not('Herpailurus yagouaroundi')).to eql(
      [:con_not, [:op_eql, :species, 'Herpailurus yagouaroundi']])
    expect(animals[:species] != 'Herpailurus yagouaroundi').to eql(
      [:con_not, [:op_eql, :species, 'Herpailurus yagouaroundi']])
  end

  # https://en.wikipedia.org/wiki/Quokka
  it '#like (=~)' do
    expect(animals[:species].like('Setonix brachyurus')).to eql(
      [:op_prx, :species, 'Setonix brachyurus'])
    expect(animals[:species] =~ 'Setonix brachyurus').to eql(
      [:op_prx, :species, 'Setonix brachyurus'])
  end

  # https://en.wikipedia.org/wiki/Fossa_(animal)
  it '#not_like (!~)' do
    expect(animals[:species].not_like('Cryptoprocta ferox')).to eql(
      [:con_not, [:op_prx, :species, 'Cryptoprocta ferox']])
    expect(animals[:species] !~ 'Cryptoprocta ferox').to eql(
      [:con_not, [:op_prx, :species, 'Cryptoprocta ferox']])
  end

  it '#!' do
    expect(!animals[:study]).to eql([:con_not, [:op_eql, :study, :wildcard]])
  end

  it '#exists (~)' do
    expect(~animals[:description]).to eql([:op_eql, :description, :wildcard])
    expect(animals[:genus].exists).to eql([:op_eql, :genus, :wildcard])
  end

  it '#gte (>=)' do
    expect(animals[:population_count].gte(10)).to eql([:op_gte, :population_count, 10])
    expect(animals[:population_count] >= 10).to eql([:op_gte, :population_count, 10])
  end

  it '#lt (<)' do
    expect(animals[:population_count].lt(9)).to eql([:con_not, [:op_gte, :population_count, 9]])
    expect(animals[:population_count] < 9).to eql([:con_not, [:op_gte, :population_count, 9]])
  end

  it '#gt (>)' do
    expect(animals[:population_count].gt(9)).to eql([:con_not, [:op_lte, :population_count, 9]])
    expect(animals[:population_count] > 9).to eql([:con_not, [:op_lte, :population_count, 9]])
  end

  it '#bitwise (===)' do
    expect(animals[:cn].bitwise(10)).to eql([:op_eql, :cn, 10])
    expect(animals[:cn] === 10).to eql([:op_eql, :cn, 10])
  end

  it '#extensible' do
    expect(animals[:cn].extensible(10)).to eql([:op_ext, :cn, 10])
  end

  it '#oid' do
    expect(animals[:family].oid).to eql('1.3.6.1.4.1.18055.0.4.1.2.1003')
    expect(animals[:population_count].oid).to eql('1.3.6.1.4.1.18055.0.4.1.2.1010')
  end

  it '#syntax' do
    expect(animals[:family].syntax).to eql('1.3.6.1.4.1.1466.115.121.1.15')
    expect(animals[:population_count].syntax).to eql('1.3.6.1.4.1.1466.115.121.1.27')
  end

  it '#description' do
    expect(animals[:family].description).to eql('The family classification of the animal')
    expect(animals[:population_count].description).to eql('The estimated number of animals')
  end

  it '#definition' do
    expect(animals[:family].definition).to eql("( 1.3.6.1.4.1.18055.0.4.1.2.1003 NAME 'family' DESC 'The family classification of the animal' EQUALITY caseIgnoreMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 SINGLE-VALUE USAGE userApplications X-SCHEMA 'wildlife' )")
  end

  it '#original_name (to_s)' do
    expect(animals[:family].to_s).to eql('family')
    expect(animals[:population_count].original_name).to eql('populationCount')
  end

  it '#editable?' do
    expect(animals[:family].editable?).to be(true)
  end

  it '#single?' do
    expect(animals[:family].single?).to be(true)
    expect(animals[:endangered].single?).to be(true)
    expect(animals[:description].single?).to be(false)
  end

  it '#multiple?' do
    expect(animals[:cn].multiple?).to be(true)
    expect(animals[:description].multiple?).to be(true)
    expect(animals[:family].multiple?).to be(false)
  end

end
