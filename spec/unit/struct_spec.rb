require 'spec_helper'

describe ROM::Struct,
  'function to produce canonical ldap attributes' do

  include RelationSetup

  let(:formatter) {
    ->(v) { ROM::LDAP::Functions.to_method_name(v) }
  }

  describe 'default formatter' do

    it '' do
    end

  end

  describe 'custom formatter' do


    before do
      ROM::LDAP::Directory::Entity.use_formatter(formatter)
    end

    it 'infered schema is snake_case' do
      # binding.pry
      # accounts.schema.to_h.keys
    end

    after do
       ROM::LDAP::Directory::Entity.use_formatter(nil)
    end
  end
end
