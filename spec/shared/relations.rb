RSpec.shared_context 'relations' do

  include_context 'directory setup'

  let(:accounts)   { container.relations[:accounts]   }
  let(:customers)  { container.relations[:customers]  }
  let(:colleagues) { container.relations[:colleagues] }
  let(:sandbox)    { container.relations[:sandbox]    }

end
