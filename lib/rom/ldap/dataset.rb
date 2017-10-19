require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/dataset/dsl'
require 'rom/ldap/dataset/api'

module ROM
  module LDAP
    class Dataset

      extend  Initializer
      include Enumerable
      include Dry::Equalizer(:criteria)

      param  :api
      param  :table_name
      option :criteria,  default: proc { {} }
      option :generator, default: proc { DSL.new }

      private :api,
              :criteria,
              :generator,
              :table_name

      # FIXME: hack to work well with rom-sql when it loads command classes
      def db
        ::OpenStruct.new(db: ::OpenStruct.new(database_type: :ldap) )
      end

      def build(args, &block)
        new_criteria = {"_#{__callee__}" => args}
        @criteria    = Functions[:deep_merge][criteria, new_criteria]
        self
      end
      private :build

      DSL.query_methods.each do |m|
        alias_method m, :build
      end

      def each(*args, &block)
        results = search
        reset!
        # binding.pry
        return results.lazy unless block_given?
        # results.lazy.each(&block).send(__callee__, *args)
        results.lazy.send(__callee__, *args, &block)
      end

      # Respond to repository methods by first calling #each
      #
      alias_method :as,       :each
      alias_method :map_to,   :each
      alias_method :map_with, :each
      alias_method :one!,     :each
      alias_method :one,      :each
      alias_method :to_a,     :each
      alias_method :with,     :each


      # Reset the current criteria
      #
      # @return [Integer]
      # @public
      #
      def count
        api.count(to_filter)
      end

      # Reset the current criteria
      #
      # @return [ROM::LDAP::Dataset]
      # @private
      #
      def reset!
        @criteria = {}
        self
      end
      private :reset!

      # @return [Net::LDAP::Filter]
      #
      def to_filter
        begin
          generator[criteria]
        rescue Net::LDAP::FilterSyntaxInvalidError
          reset!
          table_name
        end
      end

      # Inspect dataset revealing current filter criteria
      #
      # @return [String]
      #
      def inspect
        %(#<#{self.class} filter='#{to_filter}'>)
      end

      # True if password binds for the filtered dataset
      #
      # @param password [String]
      # @return [Boolean]
      #
      def authenticated?(password)
        api.bind_as(filter: to_filter, password: password)
      end

      # @return [Boolean]
      #
      def exist?
        results = api.exist?(to_filter)
        reset!
        results
      end

      # http://www.rubydoc.info/gems/ruby-net-ldap/Net%2FLDAP:add
      #
      # @param tuple [Hash]
      # @return [Boolean]
      #
      def add(tuple)
        api.add(tuple)
      end

      # http://www.rubydoc.info/gems/ruby-net-ldap/Net%2FLDAP:modify
      #
      def modify(tuples, args)
        tuples.each do |t|
          api.modify(*t[:dn], args.map { |k, v| [:replace, k, v] })
        end
      end

      # http://www.rubydoc.info/gems/ruby-net-ldap/Net%2FLDAP:delete
      #
      def delete(tuples)
        tuples.each { |t| api.delete(*t[:dn]) }
      end

      # Output the dataset as an LDIF string.
      #
      # @return [String]
      #
      def to_ldif
        results = api.directory(filter: to_filter)
        reset!
        results.map(&:to_ldif).join("\n")
      end

      # @return [Array<Hash>]
      # @api private
      #
      def search(scope=nil, &block)
        api.search(to_filter, scope, &block)
      end
      private :search

    end
  end
end
