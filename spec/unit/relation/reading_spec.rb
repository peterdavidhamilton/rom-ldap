require 'spec_helper'

describe ROM::LDAP::Relation, 'reading module' do
  include RelationSetup

  let(:uid) { Faker::Internet.unique.user_name }
  let(:dn)  { "uid=#{uid},ou=users,dc=example,dc=com" }

  before { factories[:account, uid: uid, dn: dn] }
  after  { accounts.where(uid: uid).delete }

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
    names.must_equal [['test1'], ['test10']]
  end

  it '#first' do
    customers.first[:givenname].must_equal ['test1']
  end

  it '#last' do
    customers.last[:givenname].must_equal ['test9']
  end

  it '#select' do
    result = accounts.where(uid: uid).select(:dn, :uid).to_a
    result.must_equal [{ dn: [dn], uid: [uid] }]
  end

  it '#unique?' do
    accounts.where(uid: uid).unique?.must_equal(true)
  end

  it '#exist?' do
    colleagues.exist?.must_equal(true)
  end

  it '#count' do
    colleagues.count.must_equal(1)
    customers.count.must_equal(10)
    accounts.where(uid: uid).count.must_equal(1)
  end

  # FIXME: retain DN at first position
  it '#to_ldif' do
    export = <<~LDIF
      version: 3

      cn: test1
      dn: uid=test1,ou=users,dc=example,dc=com
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
      uidnumber: 1
      userpassword: {SHA}tESsBmE/yNY3lb6a0L6vVQEZNqw=

    LDIF
      # userpassword:: e1NIQX10RVNzQm1FL3lOWTNsYjZhMEw2dlZRRVpOcXc9

    accounts.where(uid: 'test1').to_ldif.must_equal(export)
  end
end
