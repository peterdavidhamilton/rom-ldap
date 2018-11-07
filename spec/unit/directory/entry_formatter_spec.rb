RSpec.describe ROM::LDAP::Directory::Entry, '#rename' do

  include_context 'directory'

  before do
    directory.add(
      dn: 'ou=specs,dc=rom,dc=ldap',
      ou: 'specs',
      objectClass: %w'organizationalUnit top'
    )

    directory.add(
      dn: 'cn=foo,ou=specs,dc=rom,dc=ldap',
      cn: 'foo',
      sn: 'bar',
      objectClass: %w'inetOrgPerson'
    )
  end

  after do
    directory.delete('cn=foo,ou=specs,dc=rom,dc=ldap')
    directory.delete('ou=specs,dc=rom,dc=ldap')
  end

  subject(:entry) { ROM::LDAP::Directory::Entry }

  let(:attributes) { relations.people.schema.to_h.keys }


  context 'when formatter is nil' do

    before do
      entry.use_formatter(nil)
      conf.relation(:people) { schema('(objectClass=person)', infer: true) }
    end

    it 'has no effect, leaving attribute name unaltered' do

      expect(entry.rename('=HELLO World')).to eql('=HELLO World')

      expect(attributes).to include(*%w[
                                        cn
                                        createTimestamp
                                        creatorsName
                                        dn
                                        entryCSN
                                        entryDN
                                        entryParentId
                                        entryUUID
                                        nbChildren
                                        nbSubordinates
                                        objectClass
                                        sn
                                        subschemaSubentry
                                      ])
    end
  end



  context 'when formatter emulates Net::LDAP' do

    before do
      entry.use_formatter(downcase_formatter)
      conf.relation(:people) { schema('(objectClass=person)', infer: true) }
    end

    it 'creates lowercase symbols' do
      expect(entry.rename('=HELLO World')).to eql(:helloworld)

      expect(attributes).to include(*%i[
                                      cn
                                      createtimestamp
                                      creatorsname
                                      dn
                                      entrycsn
                                      entrydn
                                      entryparentid
                                      entryuuid
                                      nbchildren
                                      nbsubordinates
                                      objectclass
                                      sn
                                      subschemasubentry
                                    ])
    end
  end



  context 'when using the default ROM-LDAP formatter' do

    before do
      entry.use_formatter(method_formatter)
      conf.relation(:people) { schema('(objectClass=person)', infer: true) }
    end

    it 'creates attribute names compatible with Ruby methods' do
      expect(entry.rename('=HELLO World')).to eql(:hello_world)

      expect(attributes).to include(*%i[
                                      cn
                                      create_timestamp
                                      creators_name
                                      dn
                                      entry_csn
                                      entry_dn
                                      entry_parent_id
                                      entry_uuid
                                      nb_children
                                      nb_subordinates
                                      object_class
                                      sn
                                      subschema_subentry
                                    ])
    end
  end


  context 'when using a custom formatter' do

    before do
      entry.use_formatter(reverse_formatter)
      conf.relation(:people) { schema('(objectClass=person)', infer: true) }
    end

    it 'calls the formatter proc' do
      expect(entry.rename('=HELLO World')).to eql(:dlrowolleh)

      expect(attributes).to include(*%i[
                                      ditnerapyrtne
                                      diuuyrtne
                                      emansrotaerc
                                      nc
                                      nd
                                      ndyrtne
                                      nerdlihcbn
                                      ns
                                      nscyrtne
                                      pmatsemitetaerc
                                      setanidrobusbn
                                      ssalctcejbo
                                      yrtnebusamehcsbus
                                    ])
    end
  end

end
