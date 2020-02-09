RSpec.describe ROM::LDAP::Schema::TypeBuilder do

  context 'when inferring the schema' do
    include_context 'dragons'

    describe 'coerces auto_struct attributes' do

      subject(:struct) { dragons.to_a.last }

      it 'to String' do
        expect(struct.fetch(:species)).to be_a(String)
      end

      it 'to Integer' do
        expect(struct.fetch(:population_count)).to be_a(Integer)
      end

      it 'to Time' do
        expect(struct.fetch(:discovery_date)).to be_a(Time)
      end

      it 'to TrueClass or FalseClass' do
        expect(struct.fetch(:extinct)).to be_a(TrueClass)
        expect(struct.fetch(:endangered)).to be_a(FalseClass)
      end
    end
  end

  context 'when inferring the schema' do

    include_context 'people'

    let(:descriptions) do
      people.schema.to_h.values.map { |attr|
        [attr.name, attr.type.meta[:description]]
      }.sort.to_h
    end

    describe 'builds directory schema into attribute metadata if available' do
      with_vendors do
        it do
          case vendor
          when 'apache_ds'
            expect(descriptions.fetch(:cn)).to eql("RFC2256: common name(s) for which the entity is known by")
          when 'open_ldap'
            expect(descriptions.fetch(:cn)).to eql("RFC4519: common name(s) for which the entity is known by")
          when '389_ds', 'open_dj'
            expect(descriptions.fetch(:cn)).to eql(nil)
          end
        end


        it do
          case vendor
          when 'apache_ds', 'open_dj'
            expect(descriptions.fetch(:gid_number)).to eql("An integer uniquely identifying a group in an administrative domain")
          when 'open_ldap'
            expect(descriptions.fetch(:gid_number)).to eql("RFC2307: An integer uniquely identifying a group in an administrative domain")
          when '389_ds'
            expect(descriptions.fetch(:gid_number)).to eql("Standard LDAP attribute type")
          end
        end

      end
    end

  end
end
