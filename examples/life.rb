cwd = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
$LOAD_PATH.unshift(cwd)

# rake ldif\['../../examples/schema'\]
# rake ldif\['../../examples/animals'\]

require 'pry-byebug'
require 'rom-ldap'

# Apply a function to convert all entity
# attributes into acceptible ruby method names.
#
ROM::LDAP::Directory::Entity.to_method_name!

conf = ROM::Configuration.new(
  directory: [
    :ldap,
    { server: '127.0.0.1:10389', username: 'uid=admin,ou=system', password: 'secret' },
    { base: 'dc=example,dc=com' }
  ]
)

conf.relation(:animals, adapter: :ldap) do
  gateway :directory
  base    'dc=example,dc=com'.freeze
  # branches({
  #           pets: 'cn=domestic,ou=groups,dc=example,dc=com',
  #           zoo:  'cn=wild,ou=groups,dc=example,dc=com'
  #         }.freeze)

  schema('(species=*)', as: :animals, infer: true)
  use :pagination
  per_page 4
  use :auto_restrictions
  auto_struct false

  # def pets
  #   branch(:pets)
  # end

  #
  # Auto Restriction methods
  #
  def carnivores
    by_order('carnivora')
  end

  def great_apes
    by_family('hominidae')
  end

  def bears
    by_family('ursidae')
  end

  def common
    gte(population_count: 1_000_000)
  end

  def population_above(num)
    gte(population_count: num).order(:population_count)
  end
end

container = ROM.container(conf)
animals   = container.relations[:animals]

#
# Example Relation Methods
#
binding.pry

# pluck certain attributes
animals.select(:cn, :object_class).to_a

# grep the entity - matches within arrays
animals.where(objectclass: 'mammalia').find(/Homo/).count

# return a single struct
animals.with(auto_struct: true).where(cn: 'human').one.species
animals.with(auto_struct: true).matches(cn: 'man').one
animals.with(auto_struct: true).equals(cn: 'orangutan').one.cn

# map over multiple structs
animals.with(auto_struct: true).order(:genus).limit(10).to_a.map(&:cn)

# export to an ldif string
animals.great_apes.to_ldif

# use an alternative search base
animals.base('cn=human,ou=animals,dc=example,dc=com').one

# return specific entries
animals.by_pk('cn=Lion,ou=animals,dc=example,dc=com')
animals.fetch('cn=Lion,ou=animals,dc=example,dc=com')

# animals.zoo.search('(cn=*)').population_count
# animals.pets.page(1).search('(cn=*house*)').first
# animals.pets.page(2).pager

animals.matches(cn: 'phant').count
# animals.common_birds.to_a

# reveal inferred attributes and coerced types
animals.schema.to_h
