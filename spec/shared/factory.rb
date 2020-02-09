require 'rom-factory'

RSpec.shared_context 'factory' do |vendor|

  include_context 'vendor', vendor

  let(:factories) do
    ROM::Factory.configure { |conf| conf.rom = container }
  end

end
