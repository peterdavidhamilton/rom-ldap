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

# from ROM::Plugins::Relation::KeyInference
# use :key_inference
# def base_name
# end

      private

      # @return Boolean
      # check whether submitted attributes include the jpegphoto key
      #
      # @api private
      def image?(attrs)
        attrs.key?(options[:image])
      end
    end
  end
end
