RSpec.describe ROM::LDAP::Relation, '#combine' do

  include_context 'associations'

  before do

    researchers << { id: 1, name: 'George Edwards',  field: 'ornithology' }
    researchers << { id: 2, name: 'Dian Fossey',     field: 'primatology' }
    researchers << { id: 3, name: 'Steve Irwin',     field: 'herpetology' }
    researchers << { id: 4, name: 'Eugenie Clark',   field: 'ichthyology' }

    # These work even if the method_name formatter is active.
    # as long as the schema isn't finalised yet.
    # after species.schema.to_h these fail.
    #
    species.command(:create).call(
      [
        {
          dn:           "cn=Pangolin,#{base}",
          cn:           ['Indian Pangolin', 'Thick-tailed Pangolin', 'Scaly Anteater'],
          species:      'Manis crassicaudata',
          objectClass:  %w[mammalia extensibleObject],
          study:        'mammalology',
          labeledURI:   'https://en.wikipedia.org/wiki/Indian_pangolin'
        },
        {
          dn:           "cn=Monkey,#{base}",
          cn:           %w"Monkey Simian Ape",
          species:      'Macaca sylvanus',
          objectClass:  %w[mammalia extensibleObject],
          study:        'primatology',
          labeledURI:   'https://en.wikipedia.org/wiki/Barbary_macaque'
        },
        {
          dn:           "cn=Great White Shark,#{base}",
          cn:           'Great White Shark',
          species:      'Carcharodon carcharias',
          objectClass:  %w[chondrichthyes extensibleObject],
          study:        'ichthyology',
          labeledURI:   'https://en.wikipedia.org/wiki/Great_white_shark'
        }
      ]
    )
  end


  after do
    species.delete
  end

  xdescribe '#combine' do

    let(:primatologist) { researchers.restrict(id: 2) }

    let(:monkey) { species.by_name('monkey') }
    let(:shark)  { species.by_name('great white shark') }

    it 'totals match' do
      expect(species.count).to eql(3)
      expect(researchers.count).to eql(4)
    end

    it '#restrict' do
      expect(researchers.for_animals(monkey).one).to include(name: 'Dian Fossey')
      expect(researchers.for_animals(shark).one).to include(field: 'ichthyology')
      expect(species.for_researchers(primatologist).one).to include(study: ['primatology'])
    end

    it '#combine_with' do
      researchers.combine_with(species).to_a
    end
  end

end
