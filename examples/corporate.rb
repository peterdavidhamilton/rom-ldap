#!/usr/bin/env ruby
#
# A demonstration of rom-ldap using a typical corporate
# environment as an example dataset in an OpenLDAP directory.
#
#

require 'bundler/setup'
Bundler.setup

require 'pry-byebug'
require 'rom-ldap'
require 'rom-repository'
require 'rom-changeset'
require 'rom/transformer'


#
# Entity
# =============================================================================
module Entities
  class User < ROM::Struct
    transform_types(&:omittable)

    def common_name
      cn.first.upcase
    end
  end
end



#
# Configuration
# =============================================================================
config = ROM::Configuration.new(:ldap, nil, extensions: %i[compatibility dsml_export])



#
# Repository
# =============================================================================
class UsersRepo < ROM::Repository[:users]
  commands :create,
           update: %i[by_uid],
           delete: %i[by_uid]

  struct_namespace Entities

end



#
# Commands
# =============================================================================
class CreateUser < ROM::Commands::Create[:ldap]
  relation :users
  register_as :create
end

class UpdateUser < ROM::Commands::Update[:ldap]
  relation :users
  result :one
  register_as :update
end

class DeleteUser < ROM::Commands::Delete[:ldap]
  relation :users
  result :one
  register_as :delete
end

#
# Changeset
#
# =============================================================================
class NewUser < ROM::Changeset::Create[:users]
  map do |tuple|
    { dn: "uid=#{tuple[:uid]},ou=users,dc=rom,dc=ldap", **tuple }
  end
end



config.relation(:users) do
  schema('(objectClass=person)', infer: true)
  primary_key :uid
  use :auto_restrictions
end



#
# Setup
# =============================================================================
config.register_command(CreateUser, UpdateUser, DeleteUser)

container = ROM.container(config)

users = container.relations[:users]

