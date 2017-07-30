# require 'rom/initializer'
require 'rom/ldap/functions'
require 'rom/ldap/dataset/dsl'
require 'rom/ldap/dataset/api'

module ROM
  module LDAP
    class Dataset

      include ::Enumerable
      extend  ::Dry::Initializer
      include ::Dry::Equalizer(:criteria)

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
        return results.to_enum.lazy unless block_given?
        results.each(&block).send(__callee__, *args)
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
      # @return [ROM::LDAP::Dataset]
      #
      # @public
      #
      def reset!
        @criteria = {}
        self
      end


      # Net::LDAP::Filter
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
      # @return [Boolean]
      #
      def authenticated?(password)
        api.bind_as(filter: to_filter, password: password)
      end

      def exist?
        results = api.exist?(to_filter)
        reset!
        results
      end

      # http://www.rubydoc.info/gems/ruby-net-ldap/Net%2FLDAP:add
      #
      def add(tuple)
        api.add(tuple)
      end

      # http://www.rubydoc.info/gems/ruby-net-ldap/Net%2FLDAP:modify
      #
      def modify(tuples, args)
        operations = args.map { |k, v| [:replace, k, v] }

        tuples.each { |t| api.modify(*t[:dn], operations) }
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
        results = api.raw(filter: to_filter).map(&:to_ldif).join("\n")
        reset!
        results
      end

      # @return [Lazy Enumerator]of[Hash]
      #
      def search
        api.search(to_filter)
      end

      private :search

    end
  end
end
