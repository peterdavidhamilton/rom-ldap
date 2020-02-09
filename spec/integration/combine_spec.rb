RSpec.xdescribe ROM::LDAP::Relation, '#combine' do

  include_context 'associations'

  before do

    researchers << { id: 1, name: 'George Edwards',  field: 'ornithology' }
    researchers << { id: 2, name: 'Dian Fossey',     field: 'primatology' }
    researchers << { id: 3, name: 'Steve Irwin',     field: 'herpetology' }
    researchers << { id: 4, name: 'Eugenie Clark',   field: 'ichthyology' }
    researchers << { id: 5, name: 'Jane Goodall',    field: 'primatology' }

    # NB: These work even if the method_name formatter is active
    #     as long as the schema isn't finalised yet.
    #     After species.schema.to_h these fail.
    #
    organisms.command(:create).call(
      [
        {
          dn:           "cn=Pangolin,#{base}",
          cn:           ['Indian Pangolin', 'Thick-tailed Pangolin', 'Scaly Anteater'],
          species:      'Manis crassicaudata',
          objectClass:  %w{mammalia extensibleObject},
          study:        'mammalology',
          labeledURI:   'https://en.wikipedia.org/wiki/Indian_pangolin'
        },
        {
          dn:           "cn=Monkey,#{base}",
          cn:           %w{Monkey Simian Ape},
          species:      'Macaca sylvanus',
          objectClass:  %w{mammalia extensibleObject},
          study:        'primatology',
          labeledURI:   'https://en.wikipedia.org/wiki/Barbary_macaque'
        },
        {
          dn:           "cn=Great White Shark,#{base}",
          cn:           'Great White Shark',
          species:      'Carcharodon carcharias',
          objectClass:  %w{chondrichthyes extensibleObject},
          study:        'ichthyology',
          labeledURI:   'https://en.wikipedia.org/wiki/Great_white_shark'
        },
        {
          dn:           "cn=Gharial,#{base}",
          cn:           'Gharial',
          species:      'Gavialis gangeticus',
          objectClass:  %w{reptilia},
        }
      ]
    )
  end


  after do
    organisms.delete
    researchers.map { |t| researchers.delete(t) }
  end

  context 'In-Memory and LDAP relations' do
    let(:primatologists) { researchers.restrict(field: 'primatology') }
    let(:ichthyologists) { researchers.restrict(field: 'ichthyology') }
    let(:monkey) { organisms.by_name('monkey') }
    let(:shark)  { organisms.by_name('great white shark') }


    describe 'override association with a custom view' do
      it 'totals match' do
        expect(organisms.count).to eql(4)
        expect(researchers.count).to eql(5)
      end

      it 'two animals are studied by the researchers' do
        expect(
          organisms.for_researchers(researchers.associations[:organisms], researchers).count
        ).to eql(2)

        expect(
          organisms.for_researchers(researchers.associations[:organisms], researchers).order(:cn).map(:cn).to_a
        ).to eql(
          [
            ['Monkey', 'Simian', 'Ape'],
            ['Great White Shark']
          ]
        )
      end

      it 'two reasearchers are primatologists' do
        expect(
          primatologists.for_organisms(organisms.associations[:researchers], organisms).count
        ).to eql(2)

        expect(
          primatologists.for_organisms(organisms.associations[:researchers], organisms).to_a.map { |p| p[:name] }
        ).to eql(['Dian Fossey', 'Jane Goodall'])
      end


      it 'one animal is studied by the primatologists' do
        expect(
          organisms.for_researchers(researchers.associations[:organisms], primatologists).one[:species]
        ).to eql(['Macaca sylvanus'])
        # ).to eql('Macaca sylvanus')
      end


      it 'ldap relation into memory relation' do
        # ichthyologists.combine(:organisms).to_a

        expect(primatologists.combine(:organisms).to_a).to eql([
          { id: 2,
            name: 'Dian Fossey',
            field: 'primatology',
            organisms: [{
              # ...
              species: 'Macaca sylvanus'
            }]
          },
          { id: 5,
            name: 'Jane Goodall',
            field: 'primatology',
            organisms: [{
              # ...
              species: 'Macaca sylvanus'
            }]
          }
        ])
      end


      it 'memory relation into ldap relation' do
        # binding.pry
        # shark.combine(:researchers).one.to_h

        # FIXME:
        # organisms.combine(:researchers).to_a.map(&:to_h)

        expect(monkey.combine(:researchers).one.to_h).to eql({
          dn:           ['cn=Monkey,ou=specs,dc=rom,dc=ldap'],
          cn:           ['Monkey', 'Simian', 'Ape'],
          object_class: ['top', 'mammalia', 'extensibleObject'],
          labeled_uri:  ['https://en.wikipedia.org/wiki/Barbary_macaque'],
          species:      ['Macaca sylvanus'],
          study:        ['primatology'],
          researchers:  [
            { id: 2, name: 'Dian Fossey',  field: 'primatology' },
            { id: 5, name: 'Jane Goodall', field: 'primatology' }
          ]
        })
      end
    end

  end
end
