RSpec.describe ROM::LDAP::Relation do

  include_context 'factory'

  before do
    directory.add(
      dn: "cn=gadget,#{base}",
      cn: 'gadget',
      serial_number: '123',
      object_class: %w[device]
    )

    conf.relation(:devices) do
      schema('(objectClass=device)', infer: true)
    end

    factories.define(:device) do |f|
      f.cn { fake(:appliance, :equipment) }
      f.dn { |cn| "cn=#{cn},ou=specs,dc=rom,dc=ldap" }
      f.serial_number '123'
      f.object_class %w[device]
    end

    directory.delete("cn=gadget,#{base}")

    2.times { factories[:device] }
    factories[:device, serial_number: 222]

    relations[:devices].where(serial_number: 222).update(serial_number: nil)
  end

  let(:devices) { relations[:devices] }

  after { devices.delete }


  with_vendors do
    it '#missing' do
      expect(devices.count).to eql(3)
      expect(devices.missing(:serial_number).count).to eql(1)
      expect(devices.missing(:cn).count).to eql(0)
    end

    it '#has (present)' do
      expect(devices.count).to eql(3)
      expect(devices.has(:serial_number).count).to eql(2)
      expect(devices.present(:fake_attribute).count).to eql(0)
    end
  end

end
