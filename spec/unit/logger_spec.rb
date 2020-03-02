RSpec.describe 'Logger' do

  include_context 'vendor', 'apache_ds'

  subject(:new_logger) { Logger.new(IO::NULL) }

  it 'sets up a logger for directory' do

    gateway = container.gateways[:default]

    gateway.use_logger(new_logger)

    expect(gateway.logger).to be(new_logger)
    expect(directory.logger).to be(new_logger)
  end
end
