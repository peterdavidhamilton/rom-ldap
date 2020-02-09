require 'rom/ldap/directory/password'

RSpec.describe ROM::LDAP::Directory::Password do

  subject(:pwd) { ROM::LDAP::Directory::Password }

  let(:string) { 'i_am_secure' }
  let(:salt) { '46f32286494860eb762abaf3ad3643a0' }

  it 'raises error for missing password' do
    expect {
      pwd.generate(:md5, nil)
    }.to raise_error(ROM::LDAP::PasswordError, 'No password supplied')
  end

  it 'raises error for unknown encryption' do
    expect {
      pwd.generate(:unknown, string)
    }.to raise_error(ROM::LDAP::PasswordError, /Unsupported/)
  end

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
    let(:ssha) { "{SSHA}wfcMnM9z2sBm5qihja8lLQGq6mE0NmYzMjI4NjQ5NDg2MGViNzYyYWJhZjNhZDM2NDNhMA==" }

    it 'encodes ssha' do
      expect(pwd.generate(:ssha, string, salt)).to eql(ssha)
    end

    it 'checks ssha' do
      expect(pwd.check_ssha(string, ssha)).to be(true)
    end
  end

  describe 'SSHA512' do
    let(:ssha512) { "{SSHA512}i2Odj3KQ7AnVeqCcEKmhYkFxDkCaTWVMx9q4l8yTAp1PH5ramVMJTRQwIBRGbJ1umpwTZlK57RW5n80ar+9OETQ2ZjMyMjg2NDk0ODYwZWI3NjJhYmFmM2FkMzY0M2Ew" }

    it 'encodes ssha512' do
      expect(pwd.generate(:ssha512, string, salt)).to eql(ssha512)
    end

    it 'checks ssha512' do
      expect(pwd.check_ssha512(string, ssha512)).to be(true)
    end
  end
end
