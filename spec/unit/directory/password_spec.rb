RSpec.describe ROM::LDAP::Directory::Password do

  subject(:pwd) { ROM::LDAP::Directory::Password }

  let(:string) { 'i_am_secure' }
  let(:salt) { '46f32286494860eb762abaf3ad3643a0' }

  describe 'MD5' do
    let(:md5) { "{MD5}gdsPd3Tx/ZO4ZPElskkn7Q==" }

    it 'encodes md5' do
      expect(pwd.generate(:md5, string)).to eql(md5)
    end
  end

  describe 'SHA' do
    let(:sha) { "{SHA}hcn0BrJcbPVONiEFoLqC2eBohmQ=" }

    it 'encodes sha' do
      expect(sha).to eql(pwd.generate(:sha, string))
    end
  end

  describe 'SSHA' do
    let(:ssha) { "{SSHA}wfcMnM9z2sBm5qihja8lLQGq6mE0NmYzMjI4NjQ5NDg2MGViNzYyYWJhZjNh\nZDM2NDNhMA==" }

    it 'encodes ssha' do
      expect(pwd.generate(:ssha, string, salt)).to eql(ssha)
    end

    it 'checks ssha' do
      expect(pwd.check_ssha(string, ssha)).to be(true)
    end
  end
end
