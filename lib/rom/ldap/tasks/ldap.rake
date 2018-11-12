#
# Leverage LDAP env variables or RC files.
#
require 'pathname'

module ROM
  module LDAP
    module RakeSupport
      module_function

      def message
        puts "Using #{root}, set LDAPDIR=/path/to/root"
        puts "Add LDAPBINDDN password to #{passwd}" unless ldappw.readable?
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
      def modify(path:, file:)
        puts 'ldapmodify is not installed!' if ldapmodify.empty?

        path_to_ldif = "#{root.join(path)}/#{file}.ldif"

        system(ldapmodify, '-x', *auth, '-a', '-c', '-v', '-f', path_to_ldif)
      end

      private_instance_methods

      def root
        Pathname(ENV['LDAPDIR'] || Dir.pwd)
      end

      def ldappw
        root.join('ldappw')
      end

      def auth
        ['-y', ldappw.to_s] if ldappw.readable?
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


  # 'ldap:modify[posix,path/to/ldif]'
  #
  # @example
  #   $ rake ldap:modify            # => root/example/ldif/animals.ldif
  #   $ rake ldap:modify[file]      # => root/example/ldif/file.ldif
  #   $ rake ldap:modify[file,path] # => root/path/file.ldif
  #
  desc 'Use ldapmodify'
  task :modify, [:file, :path] => :env do |_t, args|
    args.with_defaults(path: 'example/ldif', file: 'wildlife/domain')
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
