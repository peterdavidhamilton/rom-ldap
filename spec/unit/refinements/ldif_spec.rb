RSpec.describe LDIF, '#to_ldif' do

  context 'with refinement' do
    using ::LDIF

    describe 'Hash' do
      it 'returns an LDIF formatted string' do
        expect( { cn: %w'foo' }.to_ldif ).to eq("cn: foo\n\n")

        expect( { cn: %w'foo bar' }.to_ldif ).to eq("cn: foo\ncn: bar\n\n")

        expect( { cn: %w'foo bar', dn: %w'dc=foo,dc=bar' }.to_ldif ).to eq("cn: foo\ncn: bar\ndn: dc=foo,dc=bar\n\n")
      end

      it 'values must respond to each' do
        expect { Hash[cn: 'baz'].to_ldif }.to raise_error(NoMethodError, /each/)
      end
    end

    describe 'Array' do
      it 'returns an LDIF formatted string' do
        expect( [].to_ldif ).to eq('')

        expect( [{}].to_ldif ).to eq("\n")

        expect( [{ cn: ['foo'] }].to_ldif ).to eq("cn: foo\n\n")
      end
    end
  end


  context 'without refinement' do
    describe 'Hash' do
      it 'raises an exception' do
        expect { Hash.new.to_ldif }.to raise_error(NoMethodError)
      end
    end

    describe 'Array' do
      it 'raises an exception' do
        expect { Array.new.to_ldif }.to raise_error(NoMethodError)
      end
    end
  end

end
