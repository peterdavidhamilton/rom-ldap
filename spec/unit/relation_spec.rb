require_relative '../spec_helper'

describe ROM::LDAP::Relation, 'ldap adapter' do
  include RelationSetup

  let(:user_name) { Faker::Internet.unique.user_name }

  before do
    factories[:account,
      uid: user_name,
      dn: "uid=#{user_name},cn=users,dc=pdh,dc=private"]
  end

  it '#where' do
    accounts.where(uid: 'pete').select(:dn, :sn, :uid).to_a.must_equal(
      [{
        dn:  ["uid=pete,cn=users,dc=pdh,dc=private"],
        uid: ["pete"],
        sn:  ["Hamilton"]
      }]
    )
  end

  it '#begins' do
    accounts.begins(uid: 'test').count.must_equal(3)
  end

  it '#above' do
    customers.count.must_equal 20
    customers.gte(gidnumber: 1051).to_a.must_be_empty
  end
end
