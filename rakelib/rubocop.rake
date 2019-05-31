begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new do |task|
    task.options << '--display-cop-names'
    task.requires << 'rubocop-performance'
  end
rescue LoadError
end
