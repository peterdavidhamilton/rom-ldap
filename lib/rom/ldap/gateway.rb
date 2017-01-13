# encoding: utf-8
# frozen_string_literal: true

require 'rom/gateway'
require 'rom/ldap/dataset'

module ROM
  module Ldap
    class Gateway < ROM::Gateway

      class << self
        attr_accessor :instance
      end

      attr_reader :connection
      attr_reader :logger
      attr_reader :options
      attr_reader :cache
      attr_reader :ldapsearch

      # cache must respond to fetch
      def initialize(ldap_params, options = {})
        @connection = connect(ldap_params)
        @options    = options
        @logger     = options[:logger]
        @cache      = options[:cache] #|| Dalli::Client.new
        @ldapsearch = Dataset.new

        # super

        self.class.instance = self
      end


      # filter = "(groupid=1025)"
      def call(filter)
        binding.pry
        dataset(filter)

        # if cache
        #   cache.fetch(filter.hash) { ldapsearch[filter] }
        # else
        #   ldapsearch[filter]
        # end
      end

      alias :[] :call

      # {
      #   host: ldap.host,
      #   port: ldap.port,
      #   base: ldap.base
      # }
      def connect(params = default_params)
        case params
        when ::Net::LDAP
          params
        else
          ::Net::LDAP.new(params)
        end
      end

      # fallback to Ladle
      def default_params
        { host: '0.0.0.0', port: 3897, base: 'dc=test' }
      end

      def schema
        # binding.pry
        []
      end

      # filter = "(groupid=1025)"
      def dataset(filter)
        if cache
          binding.pry
          cache.fetch(filter.hash) { ldapsearch[filter] }
        else
          ldapsearch[filter]
        end
      end

      # what is this?
      def dataset?(name)
        binding.pry
        # dataset.key?(name)
      end
    end
  end
end
