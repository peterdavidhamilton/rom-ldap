RSpec.shared_context 'animals' do

  include_context 'factory'

  before do

    directory.add(
      dn: "cn=foo,#{base}",
      discovery_date: '20070508200557Z',
      cn: 'foo',
      endangered: false,
      extinct: false,
      population_count: 0,
      description: 'description',
      family: 'family',
      genus: 'genus',
      labeled_uri: 'labeled_uri',
      order: 'order',
      species: 'species',
      study: 'study',
      object_class: %w[extensibleObject mammalia]
    )


    conf.relation(:animals) do
      schema('(species=*)', infer: true)
    end



    # all attributes no need to patch factory
    # only use with the method_name formatter
    #
    factories.define(:animal) do |f|

      f.create_timestamp ''
      f.creators_name ''
      f.entry_csn ''
      f.entry_dn ''
      f.entry_parent_id ''
      f.entry_uuid ''
      f.nb_children ''
      f.nb_subordinates ''
      f.subschema_subentry ''

      # animal
      f.cn do
        SecureRandom.uuid
      end

      f.dn do |cn|
        common_name = cn.is_a?(Array) ? cn.first : cn
        "cn=#{common_name},ou=specs,dc=rom,dc=ldap"
      end

      f.object_class do
        [
          'extensibleObject',
          %w[amphibia aves chondrichthyes mammalia reptilia].sample
        ]
      end

      f.study 'zoology'

      f.trait :amphibian  do |t|
        t.object_class %w'amphibia extensibleObject'
        t.study 'herpetology'
      end

      f.trait :mammal  do |t|
        t.object_class %w'mammalia extensibleObject'
        t.study 'mammology'
      end

      f.trait :reptile do |t|
        t.object_class %w'reptilia extensibleObject'
        t.study 'herpetology'
      end

      f.trait :bird do |t|
        t.object_class %w'aves extensibleObject'
        f.species %w'   '.sample
        t.study 'ornithology'
      end


      f.trait :rare_bird, %i[bird] do |t|
        f.endangered true
        f.population_count { fake(:number) }
      end

      f.trait :extinct_bird, %i[bird] do |t|
        f.extinct true
      end

      f.description 'description'

      f.discovery_date do
        fake(:date, :birthday, rand).to_time.utc.strftime("%Y%m%d%H%M%SZ")
      end

      # strings
      f.species do |genus|
        "#{genus} " + fake(:lorem, :word)
      end

      f.family { fake(:lorem, :word) }
      f.genus { fake(:lorem, :word) }
      f.order { fake(:lorem, :word) }

      f.labeled_uri do |cn|
        common_name = cn.is_a?(Array) ? cn.first : cn
        "https://en.wikipedia.org/wiki/#{common_name}"
      end
    end

    directory.delete("cn=foo,#{base}")
  end

  let(:animals) { relations[:animals] }

  after do
    animals.delete
  end

end
