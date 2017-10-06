require 'spec_helper'

describe ROM::LDAP::Relation, 'ldap adapter' do
  include RelationSetup

  let(:user_name) { Faker::Internet.unique.user_name }

  before do
    factories[:account,
      uid: user_name,
      dn: "uid=#{user_name},ou=users,dc=example,dc=com"]
  end

  after do
    accounts.where(uid: user_name).delete
  end

  it '#select' do
    result = [{
                dn:  ["uid=#{user_name},ou=users,dc=example,dc=com"],
                uid: [user_name]
              }]
    accounts.where(uid: user_name).select(:dn, :uid).to_a.must_equal(result)
  end

  it '#exist?' do
    colleagues.exist?.must_equal(true)
  end

  it '#count' do
    colleagues.count.must_equal(1)
    customers.count.must_equal(10)
    accounts.where(uid: user_name).count.must_equal(1)
  end

  it '#begins' do
    accounts.begins(uid: 'test').count.must_equal(10)
  end

  it '#to_ldif' do
    export = <<~LDIF
      dn: uid=test1,ou=users,dc=example,dc=com
      cn: test1
      gidnumber: 9998
      givenname: test1
      mail: test1@example.com
      objectclass: top
      objectclass: inetOrgPerson
      objectclass: person
      objectclass: organizationalPerson
      objectclass: extensibleObject
      sn: test1
      uid: test1
      userpassword:: e1NIQX10RVNzQm1FL3lOWTNsYjZhMEw2dlZRRVpOcXc9
    LDIF

    accounts.where(uid: 'test1').to_ldif.must_equal(export)
  end



  # it '#above' do
  #   customers.count.must_equal 11
  # end

  # customers.gte(gidnumber: 9997).to_a.must_be_empty
end
