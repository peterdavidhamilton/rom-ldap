RSpec.describe 'auto restriction' do

  with_vendors do

    before do
      directory.add(
        dn: "cn=gadget,#{base}",
        cn: 'gadget',
        serial_number: '123',
        object_class: %w[device]
      )

      conf.plugin(:ldap, relations: :auto_restrictions)

      conf.relation(:users) do
        schema('(objectClass=device)') do
          attribute :cn, ROM::LDAP::Types::String.meta(index: true)
          attribute :serial_number, ROM::LDAP::Types::Integer
        end
      end
    end

    after do
      directory.delete("cn=gadget,#{base}")
    end

    let(:users) { relations[:users] }

    it 'builds query methods with meta :index' do
      expect(users).to respond_to(:by_cn)
      expect(users).to_not respond_to(:by_serial_number)
    end

    it 'queries build equality matcher' do
      expect(users.by_cn('gadget').count).to eql(1)
      expect(users.by_cn('gad').count).to eql(0)
    end

  end

end
