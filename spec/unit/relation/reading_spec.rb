require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do
  include_context 'relations'

  let(:formatter) { old_format_proc }

  it 'default order by dn' do
    names = customers.to_a.collect { |t| t[:givenname] }
    expect(names).to eql(
      [
        ['test1'], ['test10'], ['test2'], ['test3'], ['test4'],
        ['test5'], ['test6'], ['test7'], ['test8'], ['test9']
      ]
    )
  end

  it '#reverse' do
    names = customers.reverse.to_a.collect { |t| t[:givenname] }
    expect(names).to eql(
      [
        ['test9'], ['test8'], ['test7'], ['test6'], ['test5'],
        ['test4'], ['test3'], ['test2'], ['test10'], ['test1']
      ]
    )
  end

  it '#random' do
    names = customers.random.to_a.collect { |t| t[:givenname] }
    expect(names).not_to eql(
      [
        ['test1'], ['test10'], ['test2'], ['test3'], ['test4'],
        ['test5'], ['test6'], ['test7'], ['test8'], ['test9']
      ]
    )
  end

  it '#limit' do
    names = customers.limit(2).to_a.collect { |t| t[:givenname] }
    expect(names).to eql(
      [
        ['test1'],
        ['test10']
      ]
    )
  end

  it '#first' do
    expect(customers.first[:givenname]).to eql(['test1'])
  end

  it '#last' do
    expect(customers.last[:givenname]).to eql(['test9'])
  end

  it '#select' do
    result = accounts.where(uid: 'test2').select(:appleimhandle).to_a
    expect(result).to eql([{ appleimhandle: ['@test2'] }])

    result = accounts.where(uid: 'test2').select(:appleimhandle).one
    expect(result).to have_key(:appleimhandle)
    expect(result).to_not have_key(:uid)
  end

  it '#unique?' do
    expect(accounts.where(uid: 'test3').unique?).to eql(true)
  end

  it '#any?' do
    expect(accounts.any?).to eql(true)
  end

  it '#count' do
    expect(accounts.count).to eql(11)
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
