require 'thor'
require 'ladle'
require 'tmpdir'
require 'rom/ldap/tasks/populator'

# ldap
# ----
# thor ldap:populate  # Populate LDIF schema for test LDAP server
# thor ldap:start     # Start test directory service
# thor ldap:stop      # Stop test directory service
#
module ROM
  module Ldap
    module Tasks
      class Sandbox < Thor
        include Thor::Actions

        namespace :ldap

        # Usage:
        #   thor ldap:populate
        #
        # Options:
        #   -f, [--fake=N]
        #                                  # Default: 20
        #   -t, [--test=N]
        #                                  # Default: 10
        #       [--append], [--no-append]
        #
        # Populate LDIF schema for test LDAP server
        desc 'populate', 'Populate LDIF schema for directory service'

        method_option :fake,   type: :numeric, default: 20,    aliases: '-f'
        method_option :test,   type: :numeric, default: 10,    aliases: '-t'
        method_option :append, type: :boolean, default: false, optional: true

        def populate
          start  = Time.now
          schema = populator_options[:schema]
          populator.call(fake:   options[:fake],
                         test:   options[:test],
                         append: options[:append])

          completed = Time.now - start
          say "#{schema} generated in #{completed}", :green
        end

        desc 'start', 'Start test directory service'

        def start
          Process.daemon(true, true)
          create_file(pid, force: true) { Process.pid }
          Signal.trap('TERM') { abort }
          loop do
            server.start
            sleep 360
          end
          say 'ApacheDS Ladle LDAP server running...', :green
        end

        desc 'stop', 'Stop test directory service'

        def stop
          server.stop
          run "pkill -F #{pid}"
          say 'ApacheDS Ladle LDAP server stopped.', :red
        end

        no_tasks do
          def server_options
            { domain: 'dc=example,dc=com', ldif: 'test.ldif' }
          end

          def server
            @server ||= ::Ladle::Server.new(server_options)
          end

          def populator_options
            {}
          end

          def populator
            @populator ||= ::ROM::Ldap::Tasks::Populator.new(populator_options)
          end

          def pid
            Dir.tmpdir + '/ladle.pid'
          end
        end
      end
    end
  end
end