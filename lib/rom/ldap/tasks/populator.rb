require 'dry-initializer'
require 'net/ldap'
require 'faker'
require 'logger'

#
# Generate an LDIF schema file with unique fake/test entries
#
module ROM
  module Ldap
    class Populator
      extend Dry::Initializer::Mixin

      option :schema,     default: -> { 'test.ldif'         }
      option :domain,     default: -> { 'example.com'       }
      option :base,       default: -> { 'dc=example,dc=com' }
      option :diradmin,   default: -> { 'diradmin'          }
      option :password,   default: -> { 'password'          }
      option :uid,        default: -> { 'uid'               }
      option :ou,         default: -> { 'users'             }
      option :logger,     default: -> { Logger.new(STDOUT)  }

      PERSON_CLASSES = %w[
        extensibleObject
        inetOrgPerson
        organizationalPerson
        person
        top
      ].freeze

      def call(fake:, test:)
        fake = fake.to_i || 1
        test = test.to_i || 1

        logger.info 'Generating....'

        begin
          ldif = File.open(schema.to_s, 'w')

          ldif << 'version: 1'  << "\n\n"
          ldif << domain_ou     << "\n"
          ldif << administrator << "\n"

          test_entries(test).each do |person|
            ldif << create_entry(person) << "\n"
          end

          fake_entries(fake).each do |person|
            ldif << create_entry(person) << "\n"
          end
        ensure
          ldif.close
        end

        logger.info "Saving #{schema}"
      end

      private

      def distinguished(name)
        "#{uid}=#{name},#{base}"
      end

      def local_email(name)
        "#{name}@#{domain}"
      end

      # read in from LDIF file
      #
      # def load(ldif)
      #   Net::LDAP::Dataset.read_ldif(ldif)
      # end

      def fake_entries(num)
        list = []
        while list.size < num
          user_hash = generate_identity
          next if list.any? { |existing| existing[:uid] == user_hash[:uid] }
          list << user_hash
        end
        list
      end

      def test_entries(num)
        Array.new(num) do |i|
          name = "test#{i}"
          Hash[
            dn:           distinguished(name),
            uid:          name,
            cn:           name,
            givenname:    name,
            sn:           name,
            mail:         local_email(name),
            userpassword: encrypt_password(name),
          ]
        end
      end

      def generate_identity
        title   = Faker::Name.prefix
        first   = Faker::Name.first_name
        last    = Faker::Name.last_name
        full    = [first, last].join(' ')
        name    = Faker::Internet.user_name(full, %w(. _))
        email   = Faker::Internet.email(name)
        display = [title, first, last].join(' ')

        Hash[
          dn:           distinguished(name),
          uid:          name,
          cn:           display,
          givenname:    first,
          sn:           last,
          mail:         email,
          userpassword: encrypt_password(name)
        ]
      end

      def domain_ou
        entry               = Net::LDAP::Entry.new(base)
        entry[:ou]          = ou
        entry[:objectclass] = %w[top organizationalUnit]
        entry.to_ldif
      end

      def administrator
        dn                   = distinguished(diradmin)
        entry                = Net::LDAP::Entry.new(dn)
        entry[:objectclass]  = PERSON_CLASSES
        entry[:uid]          = diradmin
        entry[:userpassword] = encrypt_password(password)
        entry[:cn]           = 'Directory Administrator'
        entry[:givenname]    = 'Directory'
        entry[:sn]           = 'Administrator'
        entry[:mail]         = local_email(diradmin)
        entry.to_ldif
      end

      # :sha or :md5 encryption
      #
      def encrypt_password(password, encryption = :sha)
        Net::LDAP::Password.generate(encryption, password)
      end

      def create_entry(attributes)
        entry               = Net::LDAP::Entry.new
        entry[:objectclass] = PERSON_CLASSES
        attributes.keys.each { |key| entry[key] = attributes[key] }
        entry.to_ldif
      end
    end
  end
end
