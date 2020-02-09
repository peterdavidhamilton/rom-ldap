RSpec.describe ROM::LDAP::Relation, '#pluck' do

  include_context 'people'

  before do
    factories[:person,
      uid: 'gambit',
      given_name: 'Remy',
      sn: 'LeBeau',
      mail: ['ragin_cajun@x-factor.org', 'gambit@x-men.com']
    ]
  end

  with_vendors do
    it 'with no attribute returns empty array' do
      expect { people.pluck }.to raise_error(ArgumentError)
    end

    it 'arguments can be formatted or original' do
      expect(people.pluck('uid')).to eql(%w{gambit})
    end

    it 'single attribute with single value' do
      expect(people.pluck(:uid)).to eql(%w{gambit})
    end

    it 'multiple attributes with single values' do
      expect(people.pluck(:uid, :sn, :given_name)).to eql([ %w{gambit LeBeau Remy} ])
    end

    it 'multiple attributes with many values' do
      expect(people.pluck(:uid, :mail)).to eql([
        [ %w{gambit}, %w{ragin_cajun@x-factor.org gambit@x-men.com} ]
      ])
    end
  end

end
