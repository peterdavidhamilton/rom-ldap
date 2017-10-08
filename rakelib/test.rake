require 'rake/testtask'

desc 'Run tests'
Rake::TestTask.new do |t|
  t.libs       = ['spec']
  t.test_files = FileList['spec/**/*_spec.rb']
  # t.warning    = true
  # t.verbose    = true
end
