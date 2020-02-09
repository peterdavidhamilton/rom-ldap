RSpec.describe ROM::LDAP::Relation do

  include_context 'people'

  with_vendors  do

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
              dn: "uid=batman,#{base}",
              cn: 'The Dark Knight',
              uid: 'batman',
              given_name: 'Bruce',
              sn: 'Wayne',
              object_class: %w[inetorgperson]
            )
          ).to be_kind_of(ROM::LDAP::Directory::Entry)

          expect(people.where(uid: 'batman').one[:cn]).to eql(['The Dark Knight'])
          expect(people.where(uid: 'batman').one[:given_name]).to eql(['Bruce'])
        end
      end
    end


    describe '#update' do
      before do
        people.insert(
          dn: "uid=hawkeye,#{base}",
          cn: 'xxx',
          uid: 'hawkeye',
          sn: 'xxx',
          object_class: %w[inetorgperson] # not extensible
        )
      end

      context 'when unsuccessful' do
        it 'returns false' do
          expect(people.where(uid: 'foo').update(mail: 'foo@bar')).to eql([])
          expect(people.where(uid: 'hawkeye').update(unknown: 'Hulk')).to eql([false])
        end
      end



      context 'when successful' do

        let(:new_dn) { "cn=Francis Barton,#{base}" }

        after do
          directory.delete(new_dn)
        end

        it 'returns the updated entry' do
          expect(people.where(uid: 'hawkeye').update(sn: 'Barton').first).to include(sn: ['Barton'])
        end

        it 'can change multiple attributes' do
          expect(people.where(uid: 'hawkeye').update(given_name: %w'Hawkeye Goliath Clint', sn: 'Barton').first).to include('givenName' => %w'Hawkeye Goliath Clint', sn: ['Barton'])
        end

        it 'can rename (changing RDN attribute)' do
          people.where(uid: 'hawkeye').update(dn: new_dn)
          expect(people.where(uid: 'hawkeye').first[:dn]).to eql([new_dn])
        end

        it 'can rename and update entry' do
          expect(people.where(uid: 'hawkeye').update(dn: new_dn, sn: 'Barton').first).to include(dn: [new_dn], sn: ['Barton'])
        end

        it 'can rename whilst also adding to RDN values' do
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
end
