require 'spec_helper'

describe ROM::LDAP::FilterError do
  include ContainerSetup

  describe 'FilterError' do
    before do
      conf.relation(:missing) { schema('invalid', infer: true) }
    end

    # it 'invalid filter syntax' do
    #   err = -> { relations.missing }.must_raise ROM::LDAP::FilterError
    #   err.message.must_match /invalid filter syntax/i
    # end
  end

end
