desc 'Run tests'
Rake::TestTask.new do |t|
  t.libs       = ['spec']
  t.test_files = FileList['spec/**/*_spec.rb']
  # t.warning    = true
  # t.verbose    = true
end

namespace :test do
  desc 'Populate server'
  task :setup do
    system 'ldapmodify -h 127.0.0.1 -p 10389 -D "uid=admin,ou=system" -w secret -a -f ./spec/support/setup.ldif'
  end
end
