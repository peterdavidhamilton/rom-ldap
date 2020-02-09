RSpec.describe ROM::LDAP::RestrictionDSL do

  with_vendors do

    before do
      directory.add(
        dn: "cn=DareDevil,#{base}",
        cn: 'DareDevil',
        sn: 'Murdock',
        object_class: 'person'
      )

      conf.relation(:users) do
        schema('(cn=*)') do
          attribute :cn, ROM::LDAP::Types::Strings
          attribute :sn, ROM::LDAP::Types::Strings
        end
      end
    end

    after do
      relations[:users].delete
    end

    let(:schema) { relations[:users].schema }

    subject(:dsl) { described_class.new(schema) }


    describe '#call evaluates the block' do
      it 'returns an LDAP AST for valid attributes' do
        expect( dsl.call { cn == 'DareDevil' } ).to eql([:op_eql, :cn, 'DareDevil'])
        expect( dsl.call { sn.is('Murdock') } ).to eql([:op_eql, :sn, 'Murdock'])
      end

      it 'returns false for undefined attributes' do
        expect( dsl.call { object_class == 'baz' } ).to eql(false)
        expect { dsl.call { unknown > 'baz' } }.to raise_error(NoMethodError, /NilClass/)
      end
    end

    describe '#method_missing' do
      it 'responds to methods matching attribute names' do
        expect(dsl.cn.name).to be(:cn)
        expect(dsl.sn.name).to be(:sn)
      end

      it 'does not respond unless method matches attribute in schema' do
        expect(dsl.object_class).to be_nil
        expect { dsl.object_class.name }.to raise_error(NoMethodError, /NilClass/)
      end
    end



    describe '#`' do
      it 'using literal filter strings' do
        expect( dsl.call { `(objectClass=foo)` } ).to eql([:op_eql, 'objectClass', 'foo'])
        expect( dsl.call { `(cn=ba*)` } ).to eql([:op_eql, 'cn', 'ba*'])
      end
    end


  end

end
