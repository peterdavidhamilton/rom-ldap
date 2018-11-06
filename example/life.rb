#!/usr/bin/env ruby
# encoding: utf-8
#
# A demonstration of rom-ldap using biological classification
# and taxonomic hierarchy as an example dataset.
#
# `$ bundle exec ruby ./life.rb`

#
# Libraries
# =============================================================================
cwd = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
$LOAD_PATH.unshift(cwd)

require 'bundler'
Bundler.require


#
# Entity
# =============================================================================
module Entities
  class Animal < ROM::LDAP::Struct
    def common_name
      cn.first.upcase
    end
  end
end

#
# Configuration
# =============================================================================
opts = {
  # OPEN LDAP
  username: 'cn=admin,dc=example,dc=org',
  password: 'admin',
  servers:  ["#{`docker-machine ip`.strip}:3897"],
  base:     'dc=example,dc=org',

  # APACHE
  # username: 'uid=admin,ou=system',
  # password: 'secret',
  # servers:  %w[127.0.0.1:10389], # defaults to ['127.0.0.1:389']
  # base:     'dc=example,dc=com', # defaults to ''

  timeout:  10,                  # defaults to 30
  logger:   Logger.new(STDOUT)   # defaults to null
}

# configuration = ROM::Configuration.new(:ldap, opts)
configuration = ROM::Configuration.new(default: [:ldap, opts], other: [:memory])

#
# Repository
# =============================================================================
class AnimalRepo < ROM::Repository[:animals]
  commands :create,
    update: %i[by_pk by_cn],
    delete: %i[by_pk by_cn]

  struct_namespace Entities

  def all
    animals.order(:modify_timestamp).to_a
  end

  def all_as_hash
    animals.with(auto_struct: false).to_a
  end

  # relation view projecting cn, description, species
  #
  def mammals
    animals.by_class('mammalia').to_a
  end

  # [
  #   {
  #     cn: [
  #       "Giant Panda",
  #       "Cat Bear",
  #       "猫熊",
  #       "Bear Cat",
  #       "熊猫"
  #     ],
  #     population_count: 50
  #   },
  #   ...
  # ]
  def endangered
    animals.endangered.to_a
  end

  def big_cat_count
    animals.by_genus('panthera').count
  end

  def extinct_meat_eaters
    animals.extinct.carnivores.to_a
  end

  def extinct_vegetarians
    animals.extinct.vegetarians.to_a
  end

  #
  # [
  #   "INDIAN PANGOLIN",
  #   "GIANT PANDA",
  #   "DOG",
  #   "POISON DART FROG",
  #   "ASIAN ELEPHANT",
  #   "ZEBRA",
  #   "LEOPARD GECKO",
  #   "CAT",
  #   "PANTHER CHAMELEON",
  #   "SUN BEAR"
  # ]
  def top_ten_by_genus
    animals.order(:genus).limit(10).to_a.map(&:common_name)
  end

  def apes_to_ldif
    animals.great_apes.to_ldif
  end

  def reptiles_to_yaml
    animals.by_class('reptilia').select(:cn, :species).to_yaml
  end

  def birds_to_json
    animals.by_class('aves').to_json
  end

  # WIP
  def with_researchers
    # animals.combine(:researchers)
    animals.combine(:researcher)
  end
end

#
# Commands
# =============================================================================
class CreateAnimal < ROM::Commands::Create[:ldap]
  relation :animals
  register_as :create
end

class UpdateAnimal < ROM::Commands::Update[:ldap]
  relation :animals
  result :one
  register_as :update
end

class DeleteAnimal < ROM::Commands::Delete[:ldap]
  relation :animals
  result :one
  register_as :delete
end

#
# Changeset
# =============================================================================
class NewAnimal < ROM::Changeset::Create[:animals]
  map do |tuple|
    tuple.merge(dn: "cn=#{tuple[:cn]},ou=animals,dc=example,dc=org")
  end
end

#
# Mapper
# =============================================================================
require 'rom/transformer'

class TransformAnimal < ROM::Transformer
  relation    :animals
  register_as :classification

  map_array do
    rename_keys modify_timestamp: :updated_at,
                create_timestamp: :created_at

    nest :taxonomy, %i[species order family genus]
    nest :status,   %i[extinct endangered population_count]
    nest :info,     %i[labeled_uri description cn]
  end
end

#
# Relation
# =============================================================================
configuration.relation(:researchers, adapter: :memory) do
  gateway :other

  schema(:researchers) do
    attribute :id,    ROM::Types::Integer
    attribute :name,  ROM::Types::String
    attribute :field, ROM::Types::String
  end

  dataset do
    data = [
      { id: 1, name: 'George Edwards', field: 'ornithology' },
      { id: 2, name: 'Dian Fossey', field: 'primatology' }
    ]
    ROM::Memory::Dataset.new(data)
  end
end

# configuration.relation(:predators, adapter: :ldap) do
#   schema '(species=*)', as: :animals, infer: true
# end

# TODO: aliased schema attribute names
configuration.relation(:animals, adapter: :ldap) do
  schema '(species=*)', as: :animals, infer: true do
    # attribute :cn,      ROM::LDAP::Types::Strings.meta(index: true, alias: :common_names)
    attribute :cn,      ROM::LDAP::Types::Strings.meta(index: true)
    attribute :study,   ROM::LDAP::Types::Symbol.meta(index: true, foreign_key: true)
    attribute :family,  ROM::LDAP::Types::String.meta(index: true)
    attribute :genus,   ROM::LDAP::Types::String.meta(index: true)
    attribute :order,   ROM::LDAP::Types::String.meta(index: true)
    attribute :species, ROM::LDAP::Types::String.meta(index: true)
    # attribute :audio,   ROM::LDAP::Types::Binary

    associations do
      # has_many :researchers
      has_one :researcher
      # has_many :predators
    end
  end

  base    'dc=example,dc=com'.freeze
  branches animals: 'ou=animals,dc=example,dc=org',
           extinct: 'ou=extinct,ou=animals,dc=example,dc=org'
  use :pagination
  per_page 4
  use :auto_restrictions
  struct_namespace Entities
  auto_struct true

  view(:endangered) do
    schema { project(:cn, :population_count) }
    relation { lte(population_count: 1_000_000) }
  end

  view(:by_class) do
    schema { project(:cn, :description, :species) }
    relation { |klass| where(object_class: klass) }
  end

  # overload default relation root with a different search base
  def root
    branch(:animals)
  end

  # alternative search base from predefined selection
  def extinct
    branch(:extinct)
  end

  # alternative search base
  def invertebrates
    base('ou=invertebrates,dc=example,dc=com')
  end

  #
  # relation with only one tuple
  def mankind
    by_pk('cn=human,ou=animals,dc=example,dc=org')
  end

  #
  # return the single tuple from the dataset using it's primary key
  #
  def lion
    fetch('cn=lion,ou=animals,dc=example,dc=org')
  end

  #
  # Auto Restriction methods
  #
  def zebra
    by_cn('ZEBRA') # NB: case insensitive
  end

  def carnivores
    by_order('carnivora')
  end

  def great_apes
    by_family('hominidae')
  end

  def bears
    by_family('ursidae')
  end

  def types_of_horse
    by_genus('equus')
  end

  #
  # Query DSL methods like: where, unequals, gte, present
  #
  def mammals
    where(objectClass: 'mammalia')
  end

  def vegetarians
    unequals(order: 'carnivora')
  end

  def population_above(num)
    gte(population_count: num)
  end

  def detailed
    present(:description)
  end

  # essentially a join table
  def members(dn)
    binding.pry
    #   group = fetch(dn)
    #   entries = group.member
    #   fetch entries
  end
end

#
# Setup
# =============================================================================
configuration.register_command(CreateAnimal)
configuration.register_command(UpdateAnimal)
configuration.register_command(DeleteAnimal)
configuration.register_command(DeleteAnimal)
configuration.register_mapper(TransformAnimal)

# attribute name formatter - loaded before ROM.container
ROM::LDAP.load_extensions :compatible_entry_attributes

container      = ROM.container(configuration)

# local variables
animals        = container.relations[:animals]
researchers    = container.relations[:researchers]
create_animals = container.commands[:animals][:create]
update_animal  = container.commands[:animals][:update]
delete_animal  = container.commands[:animals][:delete]
repo           = AnimalRepo.new(container)

#
# Data
# =============================================================================
new_animals = [
  {
    cn:               'Chinstrap Penguin',
    order:            'Sphenisciformes',
    family:           'Spheniscidae',
    genus:            'Pygoscelis',
    species:          'Pygoscelis antarcticus',
    object_class:     %w[extensibleObject aves],
    population_count: 10_000,
    extinct:          false,
    endangered:       false,
    study:            'ornithology'
  },
  {
    cn:               'Black Jumping Salamander',
    order:            'Caudata',
    family:           'Plethodontidae',
    genus:            'Ixalotriton',
    species:          'Ixalotriton niger',
    object_class:     %w[extensibleObject amphibia],
    population_count: 2_000,
    extinct:          false,
    endangered:       false
  }
]

#
# Breakpoint - Try out the examples below or output using 'ap'
# =============================================================================
binding.pry

#
# Examples
# =============================================================================

# attribute name is flexible
animals.where(objectClass: 'top').count # => 23

# filter by symbols
animals.where(cn: :zebra).count # => 1

# create new relation entries using a changeset
changeset = animals.changeset(NewAnimal, new_animals)
create_animals.call(changeset)

# update attributes for a filtered dataset
update_animal.by_cn('Black Jumping Salamander').call(endangered: true)
animals.endangered.to_a

# changeset = animals.changeset(new_animals).associate()

# delete entries
delete_animal.by_cn('Chinstrap Penguin').call
delete_animal.by_cn('Black Jumping Salamander').call

# find the directory administrator search the whole tree
animals.whole_tree.search('(0.9.2342.19200300.100.1.1=admin)').one.to_h
animals.base('').search('(uid=test1)').one

# search using UTF-8 charset
animals.with(auto_struct: false).matches(cn: '熊').to_a

# reveal inferred attributes and coerced types
animals.schema.to_h

# attribute names stored in directory
animals.schema.map(&:original_name)

# formatted attribute names of the Entry
animals.schema.map(&:name)

# select/pluck/map certain attributes
animals.select(:cn, :object_class).to_a
animals.map(:cn).to_a

# grep the entity - also matches within arrays
animals.where(objectclass: 'mammalia').find(/Homo/).count
animals.where(object_class: 'mammalia').find(/Homo/).count
animals.where(objectClass: 'mammalia').find(/Homo/).count

# return a single struct
animals.where(cn: 'human').one.species
animals.matches(cn: 'hum').one
animals.equals(cn: 'orangutan').one.cn

animals.matches(cn: 'man').to_a

animals.where(extinct: true).to_a

# return specific entries
animals.by_pk('cn=Lion,ou=animals,dc=example,dc=org')
animals.fetch('cn=Lion,ou=animals,dc=example,dc=org')

# pagination and mapping over a key
animals.map(:description).to_a
animals.page(1).map(:cn).to_a
animals.per_page(6).page(2).map(:order).to_a
animals.page(2).pager.next_page

animals.matches(cn: 'phant').count
animals.matches(cn: 'domestic').to_a

# use ROM::Transformer (Transproc gem) to transform the tuples.
animals.map_with(:classification).to_a.map { |a| a[:taxonomy] }

# output relation as a YAML, LDIF or JSON
repo.reptiles_to_yaml
repo.apes_to_ldif
repo.birds_to_json


# TODO:
# =============================================================================
# merge LDAP with other relations
# ap repo.with_researchers.to_a

# animals.combine(:researchers)
# ap animals.combine(:researcher).to_a
# ap animals.combine(researchers).to_a

# animals.members('cn=domestic,ou=groups,dc=example,dc=com').count
# animals.zoo.search('(cn=*)').population_count
# animals.pets.page(1).search('(cn=*house*)').first
# animals.pets.page(2).pager
# animals.common_birds.to_a
