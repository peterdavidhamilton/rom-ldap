RSpec.describe ROM::Relation do

  include_context 'people'

  before do
    factories[:person, cn: 'user', uid_number: 1]
  end

  describe '#select/#project' do

    context 'with arguments' do
      let(:relation) { people.select(:cn) }

      it do
        expect(relation.first).to eql(
          dn: ['cn=user,ou=specs,dc=rom,dc=ldap'],
          cn: ['user']
        )
      end

      it do
        expect(relation.with(auto_struct: true).one.to_h).to eql(
          cn: ['user']
        )
      end
    end

    context 'with a block' do
      it do
        expect(people.select { [:cn] }.first).to eql(
          dn: ['cn=user,ou=specs,dc=rom,dc=ldap'],
          cn: ['user']
        )
      end

      it do
        expect(people.with(auto_struct: true).select { [:cn] }.one.to_h).to eql(
          cn: ['user']
        )
      end

      it do
        expect(people.select { [cn] }.first).to eql(
          dn: ['cn=user,ou=specs,dc=rom,dc=ldap'],
          cn: ['user']
        )
      end

      it do
        expect(people.with(auto_struct: true).select { [cn] }.one.to_h).to eql(
          cn: ['user']
        )
      end


      # can only select by the formatted version i.e. snake_case
      xit 'works with aliases' do
        relation = people.select {
                                  [
                                    uid_number.as(:value),
                                    cn.aliased(:label)
                                  ]
                                }

        # aliases ignored
        expect(relation.first).to eql(
          cn: ['user'],
          dn: ['cn=user,ou=specs,dc=rom,dc=ldap'],
          uid_number: ['1']
        )


        expect(relation.to_a.first).to eql(
          dn: ['cn=user,ou=specs,dc=rom,dc=ldap'],
          label: ['user'],
          value: ['1']
        )

        #
        expect(relation.with(auto_struct: true).one.to_h).to eql(
          label: ['user'], # these change with the schema read types
          value: ['1']
        )
      end
    end

  end




  describe '#select_append' do

    let(:relation) { people.select(:cn).select_append(:uid_number) }

    it do
      expect(relation.first).to eql(
        cn: ['user'],
        dn: ['cn=user,ou=specs,dc=rom,dc=ldap'],
        uid_number: ['1']
      )
    end

    it do
      expect(relation.with(auto_struct: true).one.to_h).to eql(
        cn: ['user'],
        uid_number: 1
      )
    end
  end

end

