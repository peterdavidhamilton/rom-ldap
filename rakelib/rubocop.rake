# frozen_string_literal: true

# rubocop:disable Lint/SuppressedException
begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new do |task|
    task.options << '--display-cop-names'
    task.requires << 'rubocop-performance'
  end
rescue LoadError
end
# rubocop:enable Lint/SuppressedException
