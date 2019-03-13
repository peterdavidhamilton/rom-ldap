RSpec.describe ROM::LDAP::Attribute do

  include_context 'animals'

  before do
    5.times { factories[:animal] }

    factories[:animal,
      cn: 'Kakapo',
      species: 'Strigops habroptilus',
      population_count: 10_000_000_000
    ]
  end


  describe '#is' do
    subject(:attribute) { animals[:species] }

    it 'builds AST criteria' do
      expect(attribute.is('Strigops habroptilus')).to eql([:op_eql, :species, 'Strigops habroptilus'])
    end

    it 'after []' do
      expect(animals.where(attribute.is('Strigops habroptilus')).count).to eql(1)
    end

    it 'inside block' do
      expect( animals.where { species.is('Strigops habroptilus') }.count ).to eql(1)
    end
  end



  describe '#gte' do
    subject(:attribute) { animals[:population_count] }

    it 'builds AST criteria' do
      expect(attribute.gte(10)).to eql([:op_gte, :population_count, 10])
    end

    it 'after []' do
      expect(animals.where(attribute.gte(10_000_000_000)).count).to eql(1)
    end

    it 'inside block' do
      expect( animals.where { population_count.gte(10_000_000_000) }.count ).to eql(1)
    end
  end


    it '#lt' do
      expect( animals.where { population_count.lt(9_999_999_999) }.count ).to eql(5)
      expect( animals.where { population_count < 9_999_999_999 }.count ).to eql(5)
    end

    it '#gt' do
      expect( animals.where { population_count.gt(9_999_999_999) }.count ).to eql(1)
      expect( animals.where { population_count > 9_999_999_999 }.count ).to eql(1)
    end


    it '#exists' do
      expect( animals.where { genus.exists }.count ).to eql(6)
    end

  describe '#bitwise' do
    subject(:attribute) { animals[:cn] }

    it '#bitwise' do
      expect(attribute.bitwise(10)).to eql([:op_eql, :cn, 10])
    end
  end

  describe '#extensible' do
    subject(:attribute) { animals[:cn] }

    it '#extensible' do
      expect(attribute.extensible(10)).to eql([:op_ext, :cn, 10])
    end
  end



  it '#oid' do
    expect(animals[:family].oid).to eql('1.3.6.1.4.1.18055.0.4.1.2.1003')
  end

  it '#to_definition' do
    expect(animals[:family].to_definition).to eql("( 1.3.6.1.4.1.18055.0.4.1.2.1003 NAME 'family' DESC 'The family classification of the animal' EQUALITY caseIgnoreMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 SINGLE-VALUE USAGE userApplications X-SCHEMA 'wildlife' )")
  end

  it '#to_s or #original_name' do
    expect(animals[:family].to_s).to eql('family')
    expect(animals[:family].original_name).to eql('family')
  end

  it '#editable?' do
    expect(animals[:family].editable?).to be(true)
  end

  it '#single?' do
    expect(animals[:family].single?).to be(true)
  end

  it '#multiple?' do
    expect(animals[:family].multiple?).to be(false)
  end

end
