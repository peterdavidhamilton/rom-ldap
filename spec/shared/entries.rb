RSpec.shared_context 'entries' do |vendor|

  include_context 'factory', vendor

  before do

    directory.add(
      dn: "cn=entry,#{base}",
      cn: 'entry',
      object_class: %w[applicationProcess]
    )

    conf.relation(:entries) do
      schema('(objectClass=applicationProcess)', infer: true)
      use :pagination
      per_page 13
    end

    factories.define(:entry) do |f|
      f.sequence(:cn) { |n| "Entry #{n}" }
      f.dn { |cn| "cn=#{cn},ou=specs,dc=rom,dc=ldap" }
      f.object_class %w[applicationProcess]
    end

    directory.delete("cn=entry,#{base}")
  end

  let(:entries) { relations[:entries] }

  after { entries.delete }
end
