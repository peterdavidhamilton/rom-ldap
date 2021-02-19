# @example
#   load 'rom/ldap/tasks/ldif.rake'

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
  # rake 'ldif:import[examples/users.ldif]'
  #
  desc 'import'
  task :import, [:file] => :env do |_t, args|
    abort 'file is required' unless args[:file]

    timer   = Time.now.utc
    counter = 0

    ROM::LDAP::LDIF(File.read(args[:file])) do |entry|
      counter += 1
      ROM::LDAP::RakeSupport.directory.add(entry)
    end

    duration = Time.now.utc - timer

    puts "========================================="
    puts "#{counter} entries in #{duration} seconds"
  end



  #
  # Print LDIF
  # rake 'ldif:export[(cn=*)]'
  #
  desc 'export'
  task :export, [:filter] => :env do |_t, args|
    args.with_defaults(filter: '(objectClass=*)')

    using ROM::LDAP::LDIF

    directory = ROM::LDAP::RakeSupport.directory
    dataset   = ROM::LDAP::Dataset.new(directory: directory, name: args[:filter])

    puts "#"
    puts "# #{Time.now}"
    puts "# ========================================="
    puts ""
    puts dataset.export.to_ldif
  end

end
