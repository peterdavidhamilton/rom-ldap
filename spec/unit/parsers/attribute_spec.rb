RSpec.describe ROM::LDAP::Parsers::Attribute do

  include_context 'vendor'

  before do
    ROM::LDAP.use_formatter(reverse_formatter)
  end

  after do
    ROM::LDAP.use_formatter(method_formatter)
  end

  let(:attribute) do
    "( 0.9.2342.19200300.100.1.1 NAME ( 'uid' 'userid' ) DESC 'RFC1274: user identifier' EQUALITY caseIgnoreMatch SUBSTR caseIgnoreSubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 USAGE userApplications X-SCHEMA 'core' )"
  end

  let(:output) do
    ROM::LDAP::Parsers::Attribute.new(attribute).call
  end

  context 'when attribute has alternative short names' do

    describe 'first short name' do
      subject(:uid) { output.first }

      it { is_expected.to include(name: :diu) }
      it { is_expected.to include(canonical: 'uid') }

      # it ':name' do
      #   expect(uid[:name]).to eql(:diu)
      # end

      # it ':canonical' do
      #   expect(uid[:canonical]).to eql('uid')
      # end

      it ':definition' do
        expect(uid[:definition]).to eql(attribute)
      end

      it ':editable' do
        expect(uid[:editable]).to be(true)
      end

      it ':schema' do
        expect(uid[:schema]).to eql('core')
      end

      it ':matcher' do
        expect(uid[:rules][:equality]).to eql('caseIgnoreMatch')
      end

      it ':description' do
        expect(uid[:description]).to eql('RFC1274: user identifier')
      end

    end

    describe 'alternative short name' do
      subject(:userid) { output.last }

      it ':name' do
        expect(userid[:name]).to eql(:diresu)
      end

      it ':canonical' do
        expect(userid[:canonical]).to eql('userid')
      end

      it ':schema' do
        expect(userid[:schema]).to eql('core')
      end

      it ':oid' do
        expect(userid[:oid]).to eql('0.9.2342.19200300.100.1.1')
      end

      it ':syntax' do
        expect(userid[:syntax]).to eql('1.3.6.1.4.1.1466.115.121.1.15')
      end

    end

  end
end
