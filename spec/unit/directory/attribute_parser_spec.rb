RSpec.describe ROM::LDAP::Directory::AttributeParser do

  context 'attribute with multiple names' do
    let(:attribute) do
      "( 0.9.2342.19200300.100.1.1 NAME ( 'uid' 'userid' ) DESC 'RFC1274: user identifier' EQUALITY caseIgnoreMatch SUBSTR caseIgnoreSubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 USAGE userApplications X-SCHEMA 'core' )"
    end

    let(:output) { ROM::LDAP::Directory::AttributeParser.new(attribute).call }

    describe 'uid' do
      subject(:uid) { output.first }

      it ':name' do
        expect(uid[:name]).to eql('uid')
      end

      it ':source' do
        expect(uid[:source]).to eql('core')
      end

      it ':matcher' do
        expect(uid[:matcher]).to eql('caseIgnoreMatch')
      end

      it ':description' do
        expect(uid[:description]).to eql('RFC1274: user identifier')
      end

    end

    describe 'userid' do
      subject(:userid) { output.last }

      it ':name' do
        expect(userid[:name]).to eql('userid')
      end

      it ':source' do
        expect(userid[:source]).to eql('core')
      end

      it ':oid' do
        expect(userid[:oid]).to eql('1.3.6.1.4.1.1466.115.121.1.15')
      end

    end

  end
end
