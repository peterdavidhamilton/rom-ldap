RSpec.shared_context 'dragons' do

  let(:formatter) { downcase_proc }

  include_context 'directory'

  before do
    # ROM::LDAP.load_extensions :compatible_entry_attributes
    ROM::LDAP::Directory::Entry.use_formatter(formatter)

    # NAME    : dragons
    # AUTO    : by_cn, by_species
    # ENTITY  : false
    conf.relation(:dragons) do
      schema('(species=dragon)', infer: true) do
        attribute :cn,        ROM::LDAP::Types::String.meta(index: true)
        attribute :species,   ROM::LDAP::Types::String.meta(index: true)
      end
      use :auto_restrictions
      auto_struct false
    end

    # reload_attributes!
    directory.attribute_types
  end

  let(:dragons) { container.relations[:dragons]    }

  include_context 'factories'

  after do
    # reset_attributes!
    directory.class.attributes = nil
  end
end
