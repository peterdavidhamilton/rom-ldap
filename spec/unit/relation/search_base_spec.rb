RSpec.describe ROM::LDAP::Relation, 'search base' do

  include_context 'directory'

  let(:relation) { relations.office }

  with_vendors  do

    context 'when gateway sets a valid search base' do
      before do
        conf.relation(:office) do
          schema('(objectClass=*)', infer: true)
        end
      end

      it 'directory#base is permanently set by gateway' do
        expect(relation.dataset.directory.base).to eql('ou=specs,dc=rom,dc=ldap')
        expect(relation.with_base('foo').dataset.directory.base).to eql('ou=specs,dc=rom,dc=ldap')
      end

      it '#whole_tree broadens the search to the whole directory' do
        expect(relation.whole_tree.base).to eql('')
      end
    end


    context 'when gateway sets an empty search base' do
      let(:base) { '' }

      before do
        conf.relation(:office) do
          schema('(objectClass=*)', infer: true)
        end
      end

      it '#base defaults to the whole tree' do
        expect(relation.base).to eql('')
        expect(relation.dataset.opts[:base]).to eql('')
        expect(relation.dataset.directory.base).to eql('')
      end
    end



    context 'when using a named branch class attribute' do
      before do
        conf.relation(:office) do
          schema('(objectClass=*)', infer: true)

          branches finance: 'ou=finance,dc=rom,dc=ldap'
        end
      end

      it 'directory#base is unchanged' do
        expect(relation.branch(:finance).dataset.directory.base).to eql('ou=specs,dc=rom,dc=ldap')
      end

      it '#branch changes to a named search base branch' do
        expect(relation.branch(:finance).base).to eql('ou=finance,dc=rom,dc=ldap')
        expect(relation.branch(:finance).dataset.opts[:base]).to eql('ou=finance,dc=rom,dc=ldap')
      end
    end



    context 'when using the base class attribute' do
      before do
        conf.relation(:office) do
          schema('(objectClass=*)', infer: true)

          base 'ou=department,dc=rom,dc=ldap'
        end
      end

      it '#base can be overridden by the relation class' do
        expect(relation.class.base).to eql('ou=department,dc=rom,dc=ldap')
        expect(relation.base).to eql('ou=department,dc=rom,dc=ldap')
        expect(relation.dataset.opts[:base]).to eql('ou=department,dc=rom,dc=ldap')
      end

      it 'directory#base is unchanged' do
        expect(relation.dataset.directory.base).to eql('ou=specs,dc=rom,dc=ldap')
      end

      it '#with_base overrides the existing base' do
        expect(relation.with_base('ou=marketing,dc=rom,dc=ldap').base).to eql('ou=marketing,dc=rom,dc=ldap')
        expect(relation.with_base('ou=marketing,dc=rom,dc=ldap').dataset.opts[:base]).to eql('ou=marketing,dc=rom,dc=ldap')
      end
    end


  end

end
