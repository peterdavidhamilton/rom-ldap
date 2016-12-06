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

      attr_accessor :connection
      attr_accessor :logger

      def initialize(connection, options = {})
        @connection ||= connection
        @logger     = options[:logger]
        self.class.instance = self
      end

      def call(filter)
        dataset(filter)
      end

      alias :[] :call

      def dataset(filter)
        Dataset.new[filter]
      end

      def dataset?(name)
        dataset.key?(name)
      end
    end
  end
end
