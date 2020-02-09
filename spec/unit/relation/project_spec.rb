RSpec.describe ROM::Relation do

  include_context 'people'

  before do
    factories[:person, cn: 'user', uid_number: 1]
  end

  with_vendors do

    describe '#select (project)' do

      context 'with arguments' do
        subject(:relation) { people.project(:cn, :uid_number) }

        it 'returns only those attributes' do
          expect(relation.first).to eql(
            dn: ['cn=user,ou=specs,dc=rom,dc=ldap'],
            cn: ['user'],
            uid_number: ['1']
          )
          expect(relation.one.to_h).to eql(cn: ['user'], uid_number: 1)
          expect(relation.to_a.first).to eql(cn: ['user'], uid_number: 1)
        end
      end

      context 'with a block' do
        describe 'using symbols' do
          subject(:relation) { people.select { [:cn, :uid_number] } }

          it 'returns only those attributes' do
            expect(relation.first).to eql(
              dn: ['cn=user,ou=specs,dc=rom,dc=ldap'],
              cn: ['user'],
              uid_number: ['1']
            )
            expect(relation.one.to_h).to eql(cn: ['user'], uid_number: 1)
            expect(relation.to_a.first).to eql(cn: ['user'], uid_number: 1)
          end
        end


        describe 'using methods' do
          subject(:relation) { people.select { [cn, uid_number] } }

          it 'returns only those attributes' do
            expect(relation.first).to eql(
              dn: ['cn=user,ou=specs,dc=rom,dc=ldap'],
              cn: ['user'],
              uid_number: ['1']
            )
            expect(relation.one.to_h).to eql(cn: ['user'], uid_number: 1)
            expect(relation.to_a.first).to eql(cn: ['user'], uid_number: 1)
          end
        end


        describe 'using aliases' do
          subject(:relation) do
            people.select { [ uid_number.as(:value), cn.aliased(:label) ] }
          end

          it 'returns attributes renamed using their alias' do
            expect(relation.first).to eql(
              dn: ['cn=user,ou=specs,dc=rom,dc=ldap'],
              label: ['user'],
              value: ['1']
            )
            expect(relation.one.to_h).to eql(label: ['user'], value: 1)
            expect(relation.to_a.first).to eql(label: ['user'], value: 1)
          end

          it 'raise error if unformatted attribute name is used' do
            expect {
              people.select { gidNumber.as(:value) }
            }.to raise_error(NameError, /undefined local variable or method/)
          end
        end
      end
    end


    describe '#select_append' do

      subject(:relation) { people.select(:cn).select_append(:uid_number) }

      it 'adds the chosen attributes the current selection' do
        expect(relation.first).to eql(
          cn: ['user'],
          dn: ['cn=user,ou=specs,dc=rom,dc=ldap'],
          uid_number: ['1']
        )
        expect(relation.one.to_h).to eql(cn: ['user'], uid_number: 1)
        expect(relation.to_a.first).to eql(cn: ['user'], uid_number: 1)
      end
    end

  end

end
