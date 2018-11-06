RSpec.describe ROM::LDAP::Relation, 'ActiveDirectory::Helper' do

  include_context 'directory'

  context 'empty base' do
    before do
      conf.relation(:foo) do
        use :ad_helper
      end
    end

    let(:relation) { relations.foo }

    it '#ad_accounts_disabled' do
      expect(relation.ad_accounts_disabled.ldap_string).to eql("(&(&(sAMAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=2)))")
    end

    it '#ad_accounts_disabled' do
      expect(relation.ad_controllers.ldap_string).to eql("(&(&(objectcategory=computer)(userAccountControl:1.2.840.113556.1.4.803:=8192)))")
    end

    it '#ad_catalog_global' do
      expect(relation.ad_catalog_global.ldap_string).to eql("(&(|(objectcategory=nTDSDSA)(options:1.2.840.113556.1.4.803:=1)))")

      # expect(relation.ad_catalog_global.query_ast).to eql(nil)
    end
  end

end
