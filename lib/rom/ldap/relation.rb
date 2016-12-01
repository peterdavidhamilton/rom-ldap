# encoding: utf-8
# frozen_string_literal: true

require 'rom/ldap/types'
require 'rom/ldap/lookup'
require 'rom/ldap/filter'
require 'rom/ldap/dataset'
require 'rom/ldap/relation/reading'
require 'rom/ldap/relation/writing'

module ROM
  module Ldap
    class Relation < ROM::Relation

      adapter :ldap

      include Reading
      include Writing

      # rename the image attribute used by incoming params
      option :image, type: Symbol, reader: true, default: :jpegphoto




      def adapter
        Gateway.instance
      end

      def directory
        adapter.connection
      end

      def host
        directory.host
      end



      # @return Dataset from a single filter
      #
      # @api public
      def op_status
        directory.get_operation_result
      end

      # @return Dataset from a single filter
      #
      # @api public
      def search(filter)
        Dataset.new[filter]
      end

      # @return Dataset from a chain of filters
      #
      # @api public
      def lookup
        Lookup.new(self, Filter.new)
      end


      # ROM::Relation::Name(entries)
      #
      # @api private
      def base_name
        name
      end


      private


      # @api private
      def attributes
        # keys = []
        # dataset.each { |entry| keys.push *entry.keys }
        # keys.uniq.sort.reject { |key| key.to_s.include?('-') }
        [:dn, :uid, :givenname, :sn, :cn, :objectclass]
      end

      # def known_attributes
      #   binding.pry
      #   [:mail, :jpegphoto]
      # end

      # merged before commiting to ensure minimum standard of entry
      def default_attrs
        {
        #          dn: '',
        #         uid: '',
        #   givenname: '',
        #          sn: '',
        #          cn: '',
        #   jpegphoto: 'file://../../../../../Dropbox/vi-vim-cheat-sheet.svg',
        # objectclass: ['top', 'inetorgperson', 'person']

             dn: 'uid=fallback,ou=users,dc=test',
            uid: 'fallback',
             cn: 'Mister Tester Example',
      givenname: 'Tester',
             sn: 'Example',
           mail: 'fallback@user.com',
    objectclass: ['extensibleObject',
                  'top',
                  'organizationalPerson',
                  'inetOrgPerson',
                  'person']
        }
      end

    end
  end
end
