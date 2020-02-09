RSpec.describe ROM::LDAP::LDIF, 'binary data' do

  let(:dn) { "uid=spider-woman,#{base}" }

  let(:jpeg_file) { "#{SPEC_ROOT}/fixtures/pixel.jpg" }

  let(:ldif_string) do
    <<~EOF
    dn: #{dn}
    cn: Spider Woman
    givenName: Jessica
    sn: Drew
    objectClass: extensibleObject
    objectClass: person
    jpegPhoto: <file://#{jpeg_file}
    EOF
  end

  let(:tuples) { ROM::LDAP::LDIF(ldif_string) }

  after { directory.delete(dn) }

  with_vendors do

    it 'jpegPhoto' do
      tuples.map do |tuple|
        params = ROM::LDAP::Functions[:symbolize_keys][tuple]
        entry = directory.add(params)

        expect(entry).to be_a(ROM::LDAP::Directory::Entry)

        value = entry[:jpeg_photo][0]

        expect(value[0, 2]).to eql("\xFF\xD8".b)

        expect(File.binread(jpeg_file)).to eql(value.b)

        expect(File.size(jpeg_file)).to eql(value.size)
      end

    end
  end

end
