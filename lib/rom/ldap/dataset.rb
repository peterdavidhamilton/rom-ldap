# encoding: utf-8
# frozen_string_literal: true

module ROM
  module Ldap
    class Dataset

      attr_accessor :connection
      attr_accessor :cache

      def initialize(connection = nil, cache = nil)
        @connection = connection || Gateway.instance.connection
        # @cache = cache   || Dalli::Client.new('localhost:11211', compress: true)
      end

      def call(filter = nil)
        #unless cache
          query_directory(filter)
        #else
          #return cache.get(filter.to_s) if cache.touch(filter.to_s)
          #dataset = query_directory(filter)
          #cache.set(filter.to_s, dataset)
          #dataset
        #end
      end

      alias :[] :call

      private

      def query_directory(filter)
        begin
          entries_to_hashes connection.search(filter: filter)
        rescue ::Net::LDAP::Error
          logger.error 'rom-ldap failed to connect to server'
          return [] # return empty array as result to dataset
        end
      end

      # convert Net::LDAP::Entry to hash
      #
      # @api private
      def entries_to_hashes(array = [])
        array.map(&->(entry){entry.instance_variable_get(:@myhash)} )
      end

      def logger
        Gateway.instance.logger
      end

    end
  end
end
