require 'rom/ldap'

module ROM
  module LDAP
    module RakeSupport
      module_function

      def directory
        @directory ||= config.gateways[:default].directory
      end

      private_instance_methods

      def config
        @config ||= ROM::Configuration.new(:ldap)
      end

      def container
        @container ||= ROM.container(config)
      end

    end
  end
end


namespace :ldif do
  task :env do
    # ENV['DEBUG'] = 'y'
  end


  #
  # Parse and import LDIF file
  #
  desc 'import'
  task :import, [:file] => :env do |_t, args|
    abort 'file is required' unless args[:file]

    current = ROM::LDAP::RakeSupport.directory.base_total
    timer   = Time.now.utc
    counter = 0

    ROM::LDAP::LDIF(File.read(args[:file])) do |entry|
      counter += 1
      ROM::LDAP::RakeSupport.directory.add(entry)
    end

    added    = ROM::LDAP::RakeSupport.directory.base_total - current
    duration = Time.now.utc - timer

    puts "========================================="
    puts "#{counter} entries attempted"
    puts "#{added} entries added in #{duration} seconds"
  end



  desc 'export'
  task :export, [:filter, :attrs] => :env do |_t, args|
    args.with_defaults(attrs: "+ \\*", filter: '(objectClass=*)')

  end

end
