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

      # cache must respond to fetch
      def initialize(ldap_params, options = {})
        @connection = connect(ldap_params)
        @options    = options
        @logger     = options[:logger]
        @cache      = options[:cache] #|| Dalli::Client.new

        self.class.instance = self
      end

      # filter = "(groupid=1025)"
      def call(filter)
        if cache
          binding.pry
          cache.fetch(filter.hash) { dataset(filter) }
        else
          dataset(filter)
        end
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
        Hash[host: '0.0.0.0', port: 3897, base: 'dc=test']
      end

      # filter = "(groupid=1025)"
      def dataset(filter)
        Dataset.new[filter]
      end

      # what is this?
      def dataset?(name)
        binding.pry
        dataset.key?(name)
      end

    end
  end
end
