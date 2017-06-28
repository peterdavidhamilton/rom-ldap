require 'dry-initializer'
require 'net/ldap'
require 'faker'
# require 'securerandom'

module ROM
  module Ldap
    module Tasks
      class Populator
        extend Dry::Initializer::Mixin

        option :schema,      default: proc { 'test.ldif' }
        option :domain,      default: proc { 'example.com' }
        option :base,        default: proc { 'ou=users,dc=example,dc=com' }
        option :diradmin,    default: proc { 'diradmin' }
        option :password,    default: proc { 'password' }
        option :uid,         default: proc { 'uid' }
        option :ou,          default: proc { 'users' }
        option :personclass, default: proc {
                                          %w(
                                            extensibleObject
                                            inetOrgPerson
                                            organizationalPerson
                                            person
                                            top
                                          ).to_enum
                                        }

        attr_reader :counter, :gid

        def call(fake: 20, test: 10, append: false, uid: 1, gid: 80)
          @gid      = gid
          @counter  = uid
          test_list = test_factory.take(test).join("\n")
          fake_list = fake_factory.take(fake).join("\n")

          if append
            schema_append(test_list)
            schema_append(fake_list)
          else
            heredoc = <<-LDIF
            version: 1
            #{domain_ou}
            #{administrator}
            #{test_list}
            #{fake_list}

            LDIF
            regex  = heredoc.scan(/^[ \t]+(?=\S)/).min
            header = heredoc.gsub(/^#{regex}/, '')
            begin
              schema_file = File.open(schema, 'w')
              schema_file.puts header
            ensure
              schema_file.close
            end
          end

          :success
        end

        private

        def schema_append(text)
          File.open(schema, 'a') { |f| f.puts(text) }
        end

        def distinguished(name)
          "#{uid}=#{name},#{base}"
        end

        def local_email(name)
          "#{name}@#{domain}"
        end

        # read in from LDIF file
        #
        def load(ldif)
          Net::LDAP::Dataset.read_ldif(ldif)
        end

        def fake_factory
          return to_enum(__callee__) unless block_given?
          @generated = []
          loop do
            entry = generate_identity
            next if @generated.any? { |g| g[:uid] == entry[:uid] }
            @generated << entry
            yield create_entry(entry)
          end
        end

        def test_factory
          return to_enum(__callee__) unless block_given?

          loop do
            name   = "test_#{counter}"
            dn     = distinguished(name)
            email  = local_email(name)
            passwd = encrypt_password(name)

            yield create_entry(
              dn:                   dn,
              uidnumber:            counter,
              gidnumber:            gid,
              uid:                  name,
              cn:                   name,
              givenname:            name,
              sn:                   name,
              mail:                 email,
              userpassword:         passwd,
              'apple-imhandle':     name,
              # 'apple-generateduid': SecureRandom.uuid,
            )

            increment!
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
          dn      = distinguished(name)
          passwd  = encrypt_password(name)

          {
            dn:           dn,
            uidnumber:    increment!,
            gidnumber:    gid,
            uid:          name,
            cn:           display,
            givenname:    first,
            sn:           last,
            mail:         email,
            userpassword: passwd
          }
        end

        def increment!
          @counter += 1
        end

        def domain_ou
          entry               = Net::LDAP::Entry.new(base)
          entry[:ou]          = ou
          entry[:objectclass] = %w(top organizationalUnit)
          entry.to_ldif
        end

        def administrator
          dn                   = distinguished(diradmin)
          entry                = Net::LDAP::Entry.new(dn)
          entry[:uidnumber]    = 1001
          entry[:gidnumber]    = 1001
          entry[:objectclass]  = personclass
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
          return if password.nil?
          Net::LDAP::Password.generate(encryption, password)
        end

        def create_entry(attributes)
          entry               = Net::LDAP::Entry.new
          entry[:objectclass] = personclass
          attributes.keys.each { |key| entry[key] = attributes[key] }
          entry.to_ldif
        end
      end
    end
  end
end
