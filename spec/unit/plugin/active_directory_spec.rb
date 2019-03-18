RSpec.describe ROM::LDAP::Relation, 'ActiveDirectory' do

  include_context 'directory'

  context 'empty base' do
    before do
      conf.relation(:foo) do
        schema('(objectclass=*)', infer: true) # NB: note case of attr here
        use :active_directory
      end
    end

    let(:relation) { relations.foo }

    it '#ad_accounts_disabled' do
      expect(relation.ad_accounts_disabled.to_filter).to eql(
        "(&(objectclass=*)(&(sAMAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=2)))")
    end

    it '#ad_accounts_disabled' do
      expect(relation.ad_controllers.to_filter).to eql(
        "(&(objectclass=*)(&(objectcategory=computer)(userAccountControl:1.2.840.113556.1.4.803:=8192)))")
    end

    it '#ad_catalog_global' do
      expect(relation.ad_catalog_global.to_filter).to eql(
        "(&(objectclass=*)(|(objectcategory=nTDSDSA)(options:1.2.840.113556.1.4.803:=1)))")

      # expect(relation.ad_catalog_global.to_abstract).to eql(nil)
    end
  end

end
