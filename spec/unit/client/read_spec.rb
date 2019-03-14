RSpec.describe ROM::LDAP::Client, '#search' do

  include_context 'directory'

  before do
    directory.add(
      dn: 'ou=specs,dc=rom,dc=ldap',
      ou: 'specs',
      objectClass: 'organizationalUnit'
    )
  end

  let(:exp) do
    ROM::LDAP::Expression.new(:op_eql, 'objectClass', :wildcard)
  end

  subject(:pdu) { client.search(expression: exp) }

  describe 'minimum requirements' do
    it 'requires an expression keyword argument' do
      expect { client.search() }.to raise_error(
        KeyError,
        "ROM::LDAP::SearchRequest: option 'expression' is required"
      )
    end

    it 'expression must respond #to_ber' do
      expect { client.search(expression: nil) }.to raise_error(NoMethodError, /to_ber/)
    end
  end


  describe ':search_result' do
    it { expect(pdu.pdu_type).to eql(:search_result) }
    it { expect(pdu.message).to eql('Success') }
    it { expect(pdu.info).to eql('Indicates the requested client operation completed successfully.') }
    it { expect(pdu.success?).to be(true) }

    it { expect(pdu.result_code).to eql(0) }
    it { expect(pdu.app_tag).to eql(5) }
    it { expect(pdu.matched_dn).to eql('') }
  end

  describe 'paged results' do
    subject(:pdu) { client.search(expression: exp, paged: true) }

    it { expect(pdu.result_controls.one?).to be(true) }
    it { expect(pdu.result_controls.first.oid).to eql('1.2.840.113556.1.4.319') }
    it { expect(pdu.error_message).to be_nil }
    it { expect(pdu.bind_parameters).to be_nil }
    it { expect(pdu.extended_response).to be_nil }
    it { expect(pdu.search_entry).to be_nil }
    it { expect(pdu.search_parameters).to be_nil }
    it { expect(pdu.search_referrals).to be_nil }
  end



# {
#          :expression => <#ROM::LDAP::Expression op=op_eql left=species right=*>,
#                :base => "ou=specs,dc=rom,dc=ldap",
#               :scope => 2,
#               :deref => 3,
#          :attributes => [
#         [0] "*"
#     ],
#     :attributes_only => false,
#              :sorted => [
#         [0] "populationCount"
#     ],
#               :paged => false,
#                 :max => nil,
#             :timeout => 0,
#             :reverse => false
# }

  describe 'sorted single' do
    subject(:pdu) { client.search(expression: exp, sorted: ['sn']) }

    it {
      # binding.pry
      expect(pdu.advice).to eql('Matchingrule is required for sorting by the attribute sn') }
  end

  describe 'sorted with rule' do
    # subject(:pdu) { connection.search(expression: exp, sort: [['sn', '2.5.13.2', false]]) }
    subject(:pdu) { client.search(expression: exp, sorted: [['sn', 'caseIgnoreMatch', true]]) }

    # it { expect(pdu.result_controls.one?).to be(true) }
  end


  # DefaultCoreSession#canSort()
  describe 'sorted multiple' do
    subject(:pdu) { client.search(expression: exp, sorted: ['givenname', 'sn']) }

    it 'is not currently supported by ApacheDS' do
      expect(pdu.advice).to eql('Cannot sort results based on more than one attribute')
    end
  end

  # DefaultCoreSession#canSort()
  describe 'sorted unknown' do
    subject(:pdu) { client.search(expression: exp, sorted: ['foo']) }

    it 'complains' do
      expect(pdu.advice).to eql("No attribute with the name foo exists in the server's schema")
    end
  end

#   describe 'paged and sorted results' do
#     subject(:pdu) { connection.search(expression: exp, sort: ['cn']) }
#     it {
# binding.pry
#       expect(pdu.result_controls.size).to eql(2) }
#     it { expect(pdu.advice).to eql('Matchingrule is required for sorting by the attribute cn') }
#     it { expect(pdu.result_controls).to eql('1.2.840.113556.1.4.319') }
#   end
end
