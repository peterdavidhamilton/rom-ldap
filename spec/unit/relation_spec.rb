require_relative '../spec_helper'

describe ROM::LDAP::Relation, 'ldap adapter' do
  include RelationSetup

  it '#where select' do
    accounts.where(uid: 'pete').select(:dn, :sn, :uid).to_a.must_equal([{:dn=>["uid=pete,cn=users,dc=pdh,dc=private"], :uid=>["pete"], :sn=>["Hamilton"]}])
  end

  it '#begins count' do
    accounts.begins(uid: 'test').count.must_equal(3)
  end
end
