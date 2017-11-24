require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do

  describe 'uncoerced attributes' do

    let(:formatter) { nil }
    include_context 'relations'

    it 'raise errors if unsuitable method names' do
      expect { customers.with(auto_struct: true).to_a }.to raise_error(
        NameError, "invalid attribute name `apple-imhandle'"
      )
    end

    it 'default order by dn' do
      names = customers.to_a.collect { |t| t['givenName'] }
      expect(names).to eql(
        [
          ['test1'], ['test10'], ['test2'], ['test3'], ['test4'],
          ['test5'], ['test6'], ['test7'], ['test8'], ['test9']
        ]
      )
    end

    it '#reverse' do
      names = customers.reverse.to_a.collect { |t| t['givenName'] }
      expect(names).to eql(
        [
          ['test9'], ['test8'], ['test7'], ['test6'], ['test5'],
          ['test4'], ['test3'], ['test2'], ['test10'], ['test1']
        ]
      )
    end

    it '#random' do
      names = customers.random.to_a.collect { |t| t['givenName'] }
      expect(names).not_to eql(
        [
          ['test1'], ['test10'], ['test2'], ['test3'], ['test4'],
          ['test5'], ['test6'], ['test7'], ['test8'], ['test9']
        ]
      )
    end
  end


  describe 'snake-case coerced attributes' do
    include_context 'relations'

    let(:formatter) { method_name_proc }

    # it 'make suitable method names' do
    #   expect { customers.with(auto_struct: true).to_a }.to_not raise_error(NameError)
    # end

    it '#limit' do
      names = customers.limit(2).to_a.collect { |t| t[:given_name] }
      expect(names).to eql(
        [
          ['test1'],
          ['test10']
        ]
      )
    end
  end


  describe 'flat coerced attributes' do
    include_context 'relations'

    let(:formatter) { downcase_proc }

    # it 'make suitable method names' do
    #   expect { customers.with(auto_struct: true).to_a }.to_not raise_error(NameError)
    # end

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
  end
end
