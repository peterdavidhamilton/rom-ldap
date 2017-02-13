require 'ladle'
require 'logger'
require_relative 'populator'

task :ldap do
  Rake::application.options.show_tasks        = :tasks
  Rake::application.options.show_task_pattern = /ldap:/
  Rake::application.display_tasks_and_comments
end

namespace :ldap do
  # default env to be overridden
  #
  task :environment do
    @logger    = ::Logger.new(STDOUT)
    @populator = ::ROM::Ldap::Populator.new
    @server    = ::Ladle::Server.new
  end

  # bundle exec rake 'ldap:generate[10,20]'
  #
  desc 'Populate LDIF schema for test LDAP server'
  task :generate, [:fake, :test] => :environment do |_t, args|
    @populator.call(fake: args[:fake], test: args[:test])
  end

  desc 'Start test directory service'
  task start: :environment do
    @logger.warn 'ApacheDS Ladle LDAP starting service'
    Process.daemon(true, true)
    begin
      File.open('tmp/pids/ladle.pid', 'w') { |p| p << Process.pid }
    rescue Errno::ENOENT
      @logger.error 'check tmp/pids folder exists'
    end
    Signal.trap('TERM') { abort }
    loop do
      @server.start
      sleep 360
    end
  end

  desc 'Stop test directory service'
  task stop: :environment do
    @logger.warn 'ApacheDS Ladle LDAP stopping service'
    @server.stop
    exec "pkill -F 'tmp/pids/ladle.pid'"
  end
end
