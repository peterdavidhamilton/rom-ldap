require 'spec_helper'

describe ROM::LDAP::Schema do

  describe '#primary_key' do
    it 'returns primary key attributes' do
      schema_proc = Class.new(ROM::Relation[:ldap]).schema do
        attribute :id, ROM::LDAP::Types::Serial
      end

      schema = schema_proc.call
      schema.finalize_attributes!.finalize!

      schema.primary_key.must_equal [schema[:id]]
    end

    it 'returns empty array when there is no PK defined' do
      schema_proc = Class.new(ROM::Relation[:ldap]).schema do
        attribute :id, ROM::LDAP::Types::Int
      end

      schema = schema_proc.call
      schema.finalize_attributes!.finalize!

      schema.primary_key.must_equal []
    end
  end

end
