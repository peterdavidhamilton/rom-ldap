require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do

  include_context 'factories'

  let(:formatter) { old_format_proc }

  before { factories[:flat_account] }
  after  { accounts.where(uid: @uid).delete }

  it 'default order by dn' do
    names = customers.to_a.collect { |t| t[:givenname] }
    expect(names).to eql([
      ['test1'], ['test10'], ['test2'], ['test3'], ['test4'],
      ['test5'], ['test6'], ['test7'], ['test8'], ['test9']
    ])
  end

  it '#reverse' do
    names = customers.reverse.to_a.collect { |t| t[:givenname] }
    expect(names).to eql([
      ['test9'], ['test8'], ['test7'], ['test6'], ['test5'],
      ['test4'], ['test3'], ['test2'], ['test10'], ['test1']
    ])
  end

  it '#random' do
    names = customers.random.to_a.collect { |t| t[:givenname] }
    expect(names).not_to eql([
      ['test1'], ['test10'], ['test2'], ['test3'], ['test4'],
      ['test5'], ['test6'], ['test7'], ['test8'], ['test9']
    ])
  end

  it '#limit' do
    names = customers.limit(2).to_a.collect { |t| t[:givenname] }
    expect(names).to eql([['test1'], ['test10']])
  end

  it '#first' do
    expect(customers.first[:givenname]).to eql(['test1'])
  end

  it '#last' do
    expect(customers.last[:givenname]).to eql(['test9'])
  end

  it '#select' do
    result = accounts.where(uid: @uid).select(:dn, :uid).to_a
    expect(result).to eql([{ uid: [@uid] }])
  end

  it '#unique?' do
    expect(accounts.where(uid: user_name).unique?).to eql(true)
  end

  it '#exist?' do
    expect(colleagues.exist?).to eql(true)
  end

  it '#count' do
    expect(colleagues.count).to eql(1)
    expect(customers.count).to eql(10)
    expect(accounts.where(uid: user_name).count).to eql(1)
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

    expect(accounts.where(uid: 'test1').to_ldif).to eql(export)
  end
end
