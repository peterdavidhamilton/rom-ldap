RSpec.describe ROM::LDAP::Relation, 'server-side ordering' do

  include_context 'animals'

  context 'integers' do
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
  end

  context 'strings' do
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
  end

  context 'booleans' do
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
  end

  context 'times' do
    before do
      [[1700,12,30], [2001,12,30,15,59], [1900,12,30]].map do |args|
        factories[:animal,
          discovery_date: Time.new(*args,'+00:00').utc.strftime("%Y%m%d%H%M%SZ")
        ]
      end
    end

    it 'in chronological order' do
      expect(animals.order(:discovery_date).map(:discovery_date).to_a).to eql(
        [
          ['17001229230000Z'],
          ['19001229230000Z'],
          ['20011230155900Z']
        ]
      )
    end
  end
end
