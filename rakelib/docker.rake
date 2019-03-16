
namespace :docker do

  registry = 'registry.gitlab.com/peterdavidhamilton/rom-ldap'

  desc 'build vendor docker containers'
  task :build do
    %w[389 apacheds opendj openldap].each do |vendor|
      Dir.chdir("./docker/#{vendor}") do
        system "docker build -t #{registry}/#{vendor}:latest ."
        system "docker push #{registry}/#{vendor}:latest"
      end
    end


  end

end
