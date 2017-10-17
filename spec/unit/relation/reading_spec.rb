require 'spec_helper'

describe ROM::LDAP::Relation, 'reading module' do
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

  it 'default order by dn' do
    names = customers.to_a.collect { |t| t[:givenname] }
    names.must_equal([
      ['test1'], ['test10'], ['test2'], ['test3'], ['test4'],
      ['test5'], ['test6'], ['test7'], ['test8'], ['test9']
    ])
  end

  it '#reverse' do
    names = customers.reverse.to_a.collect { |t| t[:givenname] }
    names.must_equal([
      ['test9'], ['test8'], ['test7'], ['test6'], ['test5'],
      ['test4'], ['test3'], ['test2'], ['test10'], ['test1']
    ])
  end

  it '#random' do
    names = customers.random.to_a.collect { |t| t[:givenname] }
    names.wont_equal([
      ['test1'], ['test10'], ['test2'], ['test3'], ['test4'],
      ['test5'], ['test6'], ['test7'], ['test8'], ['test9']
    ])
  end

  it '#limit' do
    names = customers.limit(2).to_a.collect { |t| t[:givenname] }
    names.must_equal([ ['test1'], ['test10'] ])
  end

  it '#first' do
    names = customers.first.to_a.collect { |t| t[:givenname] }
    names.must_equal([ ['test1'] ])
  end

  it '#last' do
    names = customers.last.to_a.collect { |t| t[:givenname] }
    names.must_equal([ ['test9'] ])
  end

  it '#select' do
    result = [{
                dn:  ["uid=#{user_name},ou=users,dc=example,dc=com"],
                uid: [user_name]
              }]
    accounts.where(uid: user_name).select(:dn, :uid).to_a.must_equal(result)
  end

  it '#unique?' do
    accounts.where(uid: user_name).unique?.must_equal(true)
  end

  it '#exist?' do
    colleagues.exist?.must_equal(true)
  end

  it '#count' do
    colleagues.count.must_equal(1)
    customers.count.must_equal(10)
    accounts.where(uid: user_name).count.must_equal(1)
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
end
