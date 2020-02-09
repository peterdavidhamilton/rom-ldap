RSpec.describe ROM::LDAP::Relation, '#approx' do

  describe 'behaves like "=" on unsupported vendors ApacheDS' do

    include_context 'entries', 'apache_ds'

    before do
      factories[:entry, cn: 'symbol']
    end

    it 'symbol ~= cymbal' do
      expect(entries.approx(cn: 'cymbal').count).to eql(0)
      expect(entries.approx(cn: 'symbol').count).to eql(1)
    end
  end


  describe 'finds homophones on 389DS' do

    include_context 'entries', '389_ds'

    before do
      factories[:entry, cn: 'symbol']
      factories[:entry, cn: 'there']
      factories[:entry, cn: 'their']
      factories[:entry, cn: "they're"]
    end

    it 'symbol ~= cymbal' do
      expect(entries.approx(cn: 'cymbal').count).to eql(1)
    end

    # 389DS is less tolerant than OpenDJ
    #
    it "there ~= their ~= they're" do
      expect(entries.approx(cn: 'there').count).to eql(2)
      expect(entries.approx(cn: 'there').map(:cn).to_a).to eql([
        ["there"], ["their"]
      ])
    end
  end


  describe 'finds homophones on OpenDJ' do

    include_context 'entries', 'open_dj'

    context 'names' do
      before do
        factories[:entry, cn: 'John']
        factories[:entry, cn: 'Peter']
      end

      it 'John ~= jon' do
        expect(entries.approx(cn: 'jon').count).to eql(1)
      end

      it 'John ~= jonn' do
        expect(entries.approx(cn: 'jonn').count).to eql(1)
      end

      it 'Peter ~= pieter' do
        expect(entries.approx(cn: 'pieter').count).to eql(1)
      end

      it 'Peter ~= peeter' do
        expect(entries.approx(cn: 'peeter').count).to eql(1)
      end
    end

    context 'words' do

      before do
        factories[:entry, cn: 'eight']
        factories[:entry, cn: 'their']
        factories[:entry, cn: 'there']
        factories[:entry, cn: "they're"]
        factories[:entry, cn: 'symbol']
        factories[:entry, cn: "you'll"]
      end

      it 'eight ~= ate' do
        expect(entries.approx(cn: 'ate').count).to eql(1)
      end

      it "there ~= their ~= they're" do
        expect(entries.approx(cn: 'there').count).to eql(3)
      end

      it 'symbol ~= cymbal' do
        expect(entries.approx(cn: 'cymbal').count).to eql(1)
      end

      it "you'll ~= yule" do
        expect(entries.approx(cn: 'yule').count).to eql(1)
      end
    end
  end

end
