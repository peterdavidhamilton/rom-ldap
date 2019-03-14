RSpec.shared_context 'animals' do

  include_context 'factory'

  before do

    # Seed directory with data to be inferred by the relation.
    #
    directory.add(
      dn: "cn=animal,#{base}",
      cn: 'animal',
      endangered: false,
      discovery_date: '20070508200557Z',
      labeled_uri: 'labeled_uri',
      extinct: false,
      population_count: 0,
      description: 'description',
      family: 'family',
      genus: 'genus',
      order: 'order',
      species: 'species',
      study: 'study',
      object_class: %w[extensibleObject mammalia]
    )

    # Define a relation whose schema is dependent upon the entry return.
    #
    conf.relation(:animals) do
      schema('(species=*)', infer: true)
    end


    # ApacheDS Operational Attributes
    #
    # @see http://directory.apache.org/apacheds/advanced-ug/8-operational-attributes.html
    #
    # subschema_subentry  'cn=schema'
    #
    # create_timestamp    '20180301171714.514Z'
    # creators_name       '0.9.2342.19200300.100.1.1=admin,2.5.4.11=system'
    #
    # modify_timestamp    '20180301171714.514Z'
    # modifiers_name      '0.9.2342.19200300.100.1.1=admin,2.5.4.11=system'
    #
    # entry_csn           '20180827070345.021000Z#000000#001#000000'
    # entry_dn            'uid=root,ou=users,dc=example,dc=com'
    # entry_parent_id     '4c3c6602-849d-4554-8969-0f5d3901f597'
    # entry_uuid          '7791d3ce-eeb2-4eb2-9da1-ba8f9ab2e8c2'
    #
    # nb_subordinates     '0'
    # nb_children         '0'
    #
    # pwd_history         'binary data'
    #
    factories.define(:animal) do |f|

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

    # Purge temporary seed data.
    #
    directory.delete("cn=animal,#{base}")
  end

  let(:animals) { relations[:animals] }

  after do
    animals.delete
  end

end
