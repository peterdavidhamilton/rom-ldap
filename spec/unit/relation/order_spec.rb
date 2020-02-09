RSpec.describe ROM::LDAP::Relation, '#order' do

  include_context 'animals', 'apache_ds'

  describe 'integers' do
    before do
      (0..2).each { |i| factories[:animal, population_count: i] }
    end

    it 'in numerical order' do
      expect(animals.order(:population_count).project(:population_count).to_a).to eql(
        [
          { population_count: 0 },
          { population_count: 1 },
          { population_count: 2 }
        ]
      )
    end

    it 'in reverse numerical order' do
      expect(animals.order(:population_count).reverse.project(:population_count).to_a).to eql(
        [
          { population_count: 2 },
          { population_count: 1 },
          { population_count: 0 }
        ]
      )
    end

  end

  describe 'strings' do
    before do
      %w[aardvark kakapo zebra].each { |w| factories[:animal, cn: w] }
    end

    it 'in alphabetical order' do
      expect(animals.order(:cn).project(:cn).to_a).to eql(
        [
          { cn: ['aardvark'] },
          { cn: ['kakapo'] },
          { cn: ['zebra'] }
        ]
      )
    end

    it 'in reverse alphabetical order' do
      expect(animals.order(:cn).reverse.project(:cn).to_a).to eql(
        [
          { cn: ['zebra'] },
          { cn: ['kakapo'] },
          { cn: ['aardvark'] }
        ]
      )
    end

  end

  describe 'booleans' do
    before do
      [true,false,true].each { |b| factories[:animal, endangered: b] }
    end

    it 'first false then true values' do
      expect(animals.order(:endangered).project(:endangered).to_a).to eql(
        [
          { endangered: false },
          { endangered: true },
          { endangered: true }
        ]
      )
    end

    it 'first true then false values' do
      expect(animals.order(:endangered).reverse.project(:endangered).to_a).to eql(
        [
          { endangered: true },
          { endangered: true },
          { endangered: false }
        ]
      )
    end
  end

  describe 'times' do
    before do
      [[1700,12,30], [2001,12,30,15,59], [1900,12,30]].map do |args|
        factories[:animal,
          discovery_date: Time.new(*args).strftime("%Y%m%d%H%M%SZ")
        ]
      end
    end

    it 'in chronological order' do
      expect(animals.order(:discovery_date).to_a.map { |h| h[:discovery_date].to_s }).to eql(
        [
          '1700-12-30 00:00:00 UTC',
          '1900-12-30 00:00:00 UTC',
          '2001-12-30 15:59:00 UTC'
        ]
      )
      expect(animals.order(:discovery_date).map(:discovery_date).to_a).to eql(
        [
          ['17001230000000Z'],
          ['19001230000000Z'],
          ['20011230155900Z']
        ]
      )
    end

    it 'in reverse chronological order' do
      expect(animals.order(:discovery_date).reverse.to_a.map { |h| h[:discovery_date].to_s }).to eql(
        [
          '2001-12-30 15:59:00 UTC',
          '1900-12-30 00:00:00 UTC',
          '1700-12-30 00:00:00 UTC'
        ]
      )
      expect(animals.order(:discovery_date).reverse.map(:discovery_date).to_a).to eql(
        [
          ['20011230155900Z'],
          ['19001230000000Z'],
          ['17001230000000Z']
        ]
      )
    end
  end
end

