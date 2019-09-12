#
# Leverage LDAP env variables or RC files.
#
require 'pathname'
require 'pry'

module ROM
  module LDAP
    module RakeSupport
      module_function

      def message
        puts "Using #{root}, alternatively set LDAPDIR=/path/to/root"
        puts
        puts "=========================================="
      end

      # ldapsearch with simple authentication.
      #
      def search(attrs:, filter:)
        puts 'ldapsearch is not installed!' if ldapsearch.empty?
        system(ldapsearch, '-x', *auth, filter, *attrs.split('.'))
      end

      # ldapmodify with simple authentication and continuous operation.
      #
      def modify(dir: root)
        puts 'ldapmodify is not installed!' if ldapmodify.empty?

        Dir.glob("#{dir}/*.ldif") do |file|
          system(ldapmodify, '-x', *auth, '-a', '-c', '-v', '-f', file)
        end
      end

      private_instance_methods

      def root
        Pathname(ENV['LDAPDIR'] || Dir.pwd)
      end

      def ldappw
        root.join('ldappw')
      end

      def auth
        ['-w', ENV['LDAPBINDPW']]
      end

      def ldapsearch
        `which ldapsearch`.strip
      end

      def ldapmodify
        `which ldapmodify`.strip
      end
    end
  end
end


namespace :ldap do
  task :env do
    ROM::LDAP::RakeSupport.message
  end

  # Iterate through *.ldif files in a folder.
  #
  # 'ldap:modify[/schema]'
  #
  desc 'Use ldapmodify'
  task :modify, [:dir] => :env do |_t, args|
    ROM::LDAP::RakeSupport.modify(args)
  end


  # 'LDAPBASE=dc=foo ldap:search[cn=*foo,gn.sn]'
  #
  # @example
  #   $ rake ldap:search
  #   $ rake ldap:search[cn=*41,uid.mail.sn]
  #   $ rake ldap:search[gn=adele]
  #   $ rake ldap:search[userid=adele*]
  #
  desc 'Use ldapsearch'
  task :search, [:filter, :attrs] => :env do |_t, args|
    args.with_defaults(attrs: "+ \\*", filter: '(objectClass=*)')
    ROM::LDAP::RakeSupport.search(args)
  end

end
