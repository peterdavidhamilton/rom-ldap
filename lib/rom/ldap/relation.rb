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

      include Reading
      include Writing

      adapter :ldap

      # rename the image attribute used by imcoming params
      option :image, type: Symbol, reader: true, default: :jpegphoto

      def self.create_filters!
        FILTERS.each { |name| alias_method name, :filter }
      end

      FILTERS = [ :above,
                  :below,
                  :between,
                  :exclude,
                  :match,
                  :not,
                  :prefix,
                  :suffix,
                  :where,
                  :with_attribute ].freeze

      def filter(args)
        filter  = Filter.new.send(__callee__, args)
        dataset = search(filter)
        __new__(dataset)
      end

      create_filters!

      def adapter
        Gateway.instance
      end

      def directory
        adapter.connection
      end

      def host
        directory.host
      end

      def op_status
        directory.get_operation_result
      end

      def search(filter)
        Dataset.new[filter]
      end

      def lookup
        Lookup.new(self, Filter.new)
      end

      private

      # check whether submitted attributes include the jpegphoto key
      #
      # @api private
      def image?(attrs)
        attrs.key?(options[:image])
      end
    end
  end
end
