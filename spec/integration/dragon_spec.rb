RSpec.describe 'Implementation Overview' do

  include_context 'dragons'

  describe 'Directory::Entry' do
    it 'default to no struct objects returned' do
      expect(dragons.auto_struct?).to eql(false)
      expect(dragons.first).to be_a(ROM::LDAP::Directory::Entry)
      expect(dragons.to_a.first).to be_a(Hash)
      expect(dragons.one).to be_a(Hash)
    end

    it 'stuff' do
      expect(dragons.first[:species]).to eql(%w'dragon')
      expect(dragons.to_a.first[:species]).to eql('dragon')
    end

  end

  it 'criteria' do
    expect(dragons.count).to eql(1)
    expect(dragons.where(cn: 'falkor').dataset.opts[:criteria]).to eql([:op_eql, :cn, 'falkor'])
  end

  describe 'ROM::Struct' do
    subject { dragons.with(auto_struct: true).one }

    it 'structs' do
      expect(dragons.with(auto_struct: true).auto_struct?).to eql(true)
      expect(dragons.with(auto_struct: true).one).to be_a(ROM::Struct::Animal)
      expect(dragons.with(auto_struct: true).as(:dragons).one).to be_a(ROM::Struct::Dragon)
    end

    it { is_expected.to have_attributes(species: 'dragon') }
    # it { is_expected.to have_attributes(description: a_string_starting_with('Character')) }
    # it { is_expected.to have_attributes(extinct: true) }
    it { is_expected.to have_attributes(extinct: 'TRUE') }
  end

end
