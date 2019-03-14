RSpec.describe ROM::LDAP::Relation do

  include_context 'people'

  describe '#insert' do
    context 'when unsuccessful' do
      it 'raises error if missing dn' do
        expect { people.insert(cn: 'The Dark Knight') }.to raise_error(
          ROM::LDAP::OperationError, 'distinguished name is required'
        )
      end
    end


    context 'when successful' do
      it 'returns Entry object' do
        expect(
          people.insert(
            dn: 'uid=batman,ou=specs,dc=rom,dc=ldap',
            cn: 'The Dark Knight',
            uid: 'batman',
            given_name: 'Bruce',
            sn: 'Wayne',
            apple_imhandle: 'bruce-wayne',
            object_class: %w[extensibleobject inetorgperson]
          )
        ).to be_kind_of(ROM::LDAP::Directory::Entry)

        expect(people.where(uid: 'batman').one[:cn]).to eql(['The Dark Knight'])
        expect(people.where(uid: 'batman').one[:apple_imhandle]).to eql(['bruce-wayne'])
      end
    end
  end


  describe '#update' do
    before do
      factories[:person, uid: 'hawkeye']
    end

    context 'when unsuccessful' do
      it 'return an empty array for an empty dataset' do
        expect(people.where(uid: 'foo').update(mail: 'foo@bar')).to eql([])
      end

      it 'return an array of booleans' do
        expect(people.where(uid: 'hawkeye').update(missing: 'Hulk')).to eql([false])
      end
    end



    context 'when successful' do

      let(:new_dn) { 'cn=Francis Barton,dc=rom,dc=ldap' }

      after do
        directory.delete(new_dn)
      end

      it 'return the updated entry' do
        expect(people.where(uid: 'hawkeye').update(sn: 'Barton').first).to include(sn: ['Barton'])
      end

      it 'replaces multiple attributes' do
        expect(people.where(uid: 'hawkeye').update(given_name: %w'Hawkeye Goliath Clint', sn: 'Barton').first).to include('givenName' => %w'Hawkeye Goliath Clint', sn: ['Barton'])
      end

      it 'additional name' do
        expect(people.where(uid: 'hawkeye').update(cn: 'Hawkeye').first).to include(cn: ['Hawkeye'])
      end

      it 'rename and move' do
        expect(people.where(uid: 'hawkeye').update(dn: new_dn, cn: 'Hawkeye').first[:cn]).to eql(['Francis Barton', 'Hawkeye'])
      end

    end
  end


  describe '#delete' do
    before do
      factories[:person, uid: 'batman']
    end

    context 'when successful' do
      it 'return the deleted entry' do
        expect(people.where(uid: 'batman').delete.first).to be_kind_of(ROM::LDAP::Directory::Entry)
        expect(people.where(uid: 'batman').one).to be_nil
      end

      it 'return an array of deleted tuples' do
        expect(people.where(uid: 'batman').delete.first).to include(uid: ['batman'])
        # expect(people.where(uid: 'batman').delete.first[:uid]).to eql(['batman'])
        expect(people.where(uid: 'batman').one).to be_nil
      end
    end

    context 'when unsuccessful' do
      it 'return an empty array for an empty dataset' do
        expect(people.where(uid: 'bar').delete).to eql([])
      end
    end
  end

end
