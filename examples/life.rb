cwd = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
$LOAD_PATH.unshift(cwd)

require 'pry-byebug'
require 'rom-ldap'
require 'rom-repository'
require 'rom-changeset'


# Attribute name formatter
ROM::LDAP.load_extensions :compatible_entry_attributes

# Custom struct
module Entities
  class Animal < ROM::LDAP::Struct
    def common_name
      cn.first.upcase
    end
  end
end

# Configuration
configuration = ROM::Configuration.new(
  directory: [
    :ldap,
    { server: '127.0.0.1:10389', username: 'uid=admin,ou=system', password: 'secret' },
    { base: 'dc=example,dc=com' }
  ]
)

# Repository
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

  def mammals
    animals.by_class('mammalia').to_a
  end

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

  def with_keeper
    animals.combine(:account)
  end
end

# Commands
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

# Changeset
class NewAnimal < ROM::Changeset::Create[:animals]
  map do |tuple|
    tuple.merge(dn: "cn=#{tuple[:cn]},ou=animals,dc=example,dc=com")
  end
end

# Relation
configuration.relation(:animals, adapter: :ldap) do
  gateway :directory
  base    'dc=example,dc=com'.freeze
  schema  '(species=*)', as: :animals, infer: true
  branches animals: 'ou=animals,dc=example,dc=com',
           extinct: 'ou=extinct,ou=animals,dc=example,dc=com'
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
    schema { project(:species) }
    relation { |klass| where(object_class: klass) }
  end

  # overload default relation root with a different search base
  # def root
  #   branch(:animals)
  # end

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
    by_pk('cn=human,ou=animals,dc=example,dc=com')
  end

  #
  # return the single tuple from the dataset using it's primary key
  #
  def lion
    fetch('cn=lion,ou=animals,dc=example,dc=com')
  end

  #
  # Auto Restriction methods
  #
  def zebra
    by_cn('ZEBRA')
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
  # Query DSL methods
  #
  def mammals
    where(object_class: 'mammalia')
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


configuration.register_command(CreateAnimal)
configuration.register_command(UpdateAnimal)
configuration.register_command(DeleteAnimal)


container = ROM.container(configuration)
animals   = container.relations[:animals]
repo      = AnimalRepo.new(container)


create_animals = container.commands[:animals][:create]
update_animal  = container.commands[:animals][:update]
delete_animal  = container.commands[:animals][:delete]



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
    endangered:       false
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

binding.pry



changeset = animals.changeset(NewAnimal, new_animals)
create_animals.call(changeset)


update_animal.by_cn('Black Jumping Salamander').call(endangered: true)

# changeset = animals.changeset(new_animals).associate()

delete_animal.by_cn('Chinstrap Penguin').call


# administrator
animals.base('').search('(0.9.2342.19200300.100.1.1=admin)').one.to_h
animals.base('').search('(uid=test1)').one

animals.with(auto_struct: false).matches(cn: '熊').to_a

#
# reveal inferred attributes and coerced types
#
animals.schema.to_h

# pluck certain attributes
animals.with(auto_struct: true).select(:cn, :object_class).to_a
animals.with(auto_struct: false).select(:cn, :object_class).to_a

# grep the entity - matches within arrays
animals.where(objectclass: 'mammalia').find(/Homo/).count

# return a single struct
animals.where(cn: 'human').one.species
animals.matches(cn: 'man').one
animals.equals(cn: 'orangutan').one.cn

repo.reptiles_to_yaml

animals.where(extinct: true).to_a

# animals.members('cn=domestic,ou=groups,dc=example,dc=com').count

# return specific entries
animals.by_pk('cn=Lion,ou=animals,dc=example,dc=com')
animals.fetch('cn=Lion,ou=animals,dc=example,dc=com')

# animals.zoo.search('(cn=*)').population_count
# animals.pets.page(1).search('(cn=*house*)').first
# animals.pets.page(2).pager

animals.matches(cn: 'phant').count
animals.matches(cn: 'ant').to_a
# animals.common_birds.to_a


