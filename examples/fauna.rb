#!/usr/bin/env ruby
#
# A demonstration of rom-ldap using biological classification
# and taxonomic hierarchy as an example dataset in an ApacheDS directory.
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
  class Animal < ROM::Struct
    transform_types(&:omittable)

    def common_name
      cn.first.upcase
    end
  end
end



#
# Configuration
# =============================================================================
config = ROM::Configuration.new(
    default: [:ldap, nil, extensions: %i[compatibility dsml_export]],
    other: [:memory]
  )



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
    animals.by_class('reptilia').project(:cn, :species).to_yaml
  end

  def birds_to_json
    animals.by_class('aves').to_json
  end

  # [
  #   'Ailuropoda',
  #   'Canis',
  #   'Dendrobates',
  #   'Elephas',
  #   'Equus',
  #   ...
  #   'Testudo',
  #   'Turdus',
  #   'Vulpes'
  # ]
  def genera
    animals.list(:genus)
  end

  def with_researchers
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
#
# =============================================================================
class NewAnimal < ROM::Changeset::Create[:animals]
  map do |tuple|
    { dn: "cn=#{tuple[:cn]},ou=animals,dc=rom,dc=ldap", **tuple }
  end
end

#
# Mapper
# =============================================================================

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
config.relation(:researchers, adapter: :memory) do
  gateway :other

  schema(:researchers) do
    attribute :id,    ROM::Types::Integer
    attribute :name,  ROM::Types::String
    attribute :field, ROM::Types::String
  end
end


config.relation(:groups, adapter: :ldap) do
  schema '(objectClass=groupOfNames)', as: :groups, infer: true do
    # associations do
    # end
  end

  def wild_animals
    where(cn: 'Wild Animals').list(:member)
  end

  def domestic_animals
    where(cn: 'Domesticated Animals').list(:member)
  end
end


config.relation(:animals, adapter: :ldap) do
  schema '(species=*)', as: :animals, infer: true do
    # attribute :cn,      ROM::LDAP::Types::Strings.meta(index: true, alias: :common_name)
    # attribute :common_name,      ROM::LDAP::Types::Strings.meta(index: true, alias: :cn)
    attribute :cn,      ROM::LDAP::Types::Strings.meta(index: true)
    attribute :study,   ROM::LDAP::Types::Symbol.meta(index: true, foreign_key: true)
    attribute :family,  ROM::LDAP::Types::String.meta(index: true)
    attribute :genus,   ROM::LDAP::Types::String.meta(index: true)
    attribute :order,   ROM::LDAP::Types::String.meta(index: true)
    attribute :species, ROM::LDAP::Types::String.meta(index: true)
    # attribute :audio,   ROM::LDAP::Types::Binary

    # only returned with Relation#operational
    use :timestamps,
      attributes: %i(create_timestamp modify_timestamp),
      type: ROM::LDAP::Types::Time

    associations do
      # has_many :researchers
      has_one :researcher
      # has_many :predators
    end
  end

  base 'dc=rom,dc=ldap'

  branches animals: 'ou=animals,dc=rom,dc=ldap',
           extinct: 'ou=extinct,ou=animals,dc=rom,dc=ldap'

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
    relation { |klass| where { object_class == klass } }
  end

  def root
    branch(:animals)
  end

  def extinct
    branch(:extinct)
  end

  def invertebrates
    with_base('ou=invertebrates,dc=rom,dc=ldap')
  end

  # @return [Relation]
  #
  def mankind
    by_pk('cn=human,ou=animals,dc=rom,dc=ldap')
  end

  def lion
    fetch('cn=lion,ou=animals,dc=rom,dc=ldap')
  end

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

  def mammals
    where(objectClass: 'mammalia')
  end

  def vegetarians
    unequal(order: 'carnivora')
  end

  def population_above(num)
    gte(population_count: num)
  end

  def population_below(num)
    where { population_count < num }
  end

  def detailed
    present(:description)
  end

  def members(dn)
    #   group = fetch(dn)
    #   entries = group.member
    #   fetch entries
  end
end

#
# Setup
# =============================================================================
config.register_command(CreateAnimal)
config.register_command(UpdateAnimal)
config.register_command(DeleteAnimal)

config.register_mapper(TransformAnimal)


container = ROM.container(config)
# => #<ROM::Container gateways={:default=>#<ROM::LDAP::Gateway:0x00007fd9922ea248 @options={:username=>"uid=admin,ou=system", :password=>"secret", :base=>"dc=rom,dc=ldap", :logger=>#<Logger:0x00007fd9922ea860 @progname=nil, @level=0, @default_formatter=#<Logger::Formatter:0x00007fd9922ea838 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x00007fd9922ea7e8 @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDOUT>>, @mon_owner=nil, @mon_count=0, @mon_mutex=#<Thread::Mutex:0x00007fd9922ea798>>>}, @dir_opts={:base=>"dc=rom,dc=ldap", :logger=>#<Logger:0x00007fd9922ea860 @progname=nil, @level=0, @default_formatter=#<Logger::Formatter:0x00007fd9922ea838 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x00007fd9922ea7e8 @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDOUT>>, @mon_owner=nil, @mon_count=0, @mon_mutex=#<Thread::Mutex:0x00007fd9922ea798>>>}, @logger=#<Logger:0x00007fd9922ea860 @progname=nil, @level=0, @default_formatter=#<Logger::Formatter:0x00007fd9922ea838 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x00007fd9922ea7e8 @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDOUT>>, @mon_owner=nil, @mon_count=0, @mon_mutex=#<Thread::Mutex:0x00007fd9922ea798>>>, @connection=#<ROM::LDAP::Connection:0x00007fd991987660 @read_timeout=60.0, @write_timeout=60.0, @connect_timeout=10.0, @buffered=true, @connect_retry_count=10, @retry_count=3, @connect_retry_interval=0.5, @on_connect=nil, @proxy_server=nil, @policy=:ordered, @close_on_error=false, @ssl=nil, @servers=["192.168.99.100:389"], @socket=#<Socket:fd 9>, @address=#<Net::TCPClient::Address:0x00007fd992203398 @host_name="192.168.99.100", @ip_address="192.168.99.100", @port=389>, @msgid=4, @message_queue={1=>[]}>, @directory=#<ROM::LDAP::Directory servers=["192.168.99.100:389"] base='dc=rom,dc=ldap' ldap_versions=[3] vendor='Apache Software Foundation' release='2.0.0-M24' />>, :other=>#<ROM::Memory::Gateway:0x00007fd991210a58 @connection=#<ROM::Memory::Storage:0x00007fd991210a30 @data={:researchers=>#<ROM::Memory::Dataset data=[]>}>>} relations=#<ROM::RelationRegistry elements={:researchers=>#<ROM::Relation[Researchers] name=ROM::Relation::Name(researchers) dataset=#<ROM::Memory::Dataset data=[]>>, :animals=>#<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>>}> mappers=#<ROM::Registry elements={:animals=>#<ROM::MapperRegistry elements={:classification=>#<TransformAnimal:0x00007fd99192e7e0>}>}> commands=#<ROM::Registry elements={:researchers=>#<ROM::CommandRegistry elements={}>, :animals=>#<ROM::CommandRegistry elements={:create=>#<CreateAnimal relation=#<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>> options={:relation=>#<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>>, :type=>nil, :source=>#<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>>, :result=>:many, :input=>Hash, :curry_args=>[], :before=>[], :after=>[]}>, :update=>#<UpdateAnimal relation=#<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>> options={:relation=>#<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>>, :type=>nil, :source=>#<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>>, :result=>:one, :input=>Hash, :curry_args=>[], :before=>[], :after=>[:finalize]}>, :delete=>#<DeleteAnimal relation=#<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>> options={:relation=>#<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>>, :type=>nil, :source=>#<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>>, :result=>:one, :input=>Hash, :curry_args=>[], :before=>[], :after=>[]}>}>}>>

animals = container.relations[:animals]
# => #<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>>

groups = container.relations[:groups]
# =>

researchers = container.relations[:researchers]
# => #<ROM::Relation[Researchers] name=ROM::Relation::Name(researchers) dataset=#<ROM::Memory::Dataset data=[]>>


researchers << { id: 1, name: 'George Edwards',  field: 'ornithology' }
researchers << { id: 2, name: 'Dian Fossey',     field: 'primatology' }
researchers << { id: 3, name: 'Steve Irwin',     field: 'herpetology' }
researchers << { id: 4, name: 'Eugenie Clark',   field: 'ichthyology' }
researchers << { id: 5, name: 'Jane Goodall',    field: 'primatology' }


create_animals = container.commands[:animals][:create]
update_animal  = container.commands[:animals][:update]
delete_animal  = container.commands[:animals][:delete]
repo           = AnimalRepo.new(container)
# => #<AnimalRepo struct_namespace=Entities auto_struct=true>

#
# Data
# =============================================================================
new_animals = [
  {
    cn: 'Chinstrap Penguin',
    order: 'Sphenisciformes',
    family: 'Spheniscidae',
    genus: 'Pygoscelis',
    species: 'Pygoscelis antarcticus',
    object_class: %w[extensibleObject aves],
    population_count: 10_000,
    extinct: false,
    endangered: false,
    study: 'ornithology'
  },
  {
    cn: 'Black Jumping Salamander',
    order: 'Caudata',
    family: 'Plethodontidae',
    genus: 'Ixalotriton',
    species: 'Ixalotriton niger',
    object_class: %w[extensibleObject amphibia],
    population_count: 2_000,
    extinct: false,
    endangered: false
    # study: 'herpetology'
  }
]



#
# Examples
# =============================================================================
binding.pry # breakpoint

animals.count # => 26

animals.where(cn: :zebra).count # => 1

changeset = animals.changeset(NewAnimal, new_animals)
# => #<NewAnimal relation=ROM::Relation::Name(animals on (species=*)) data=[{:cn=>"Chinstrap Penguin", :order=>"Sphenisciformes", :family=>"Spheniscidae", :genus=>"Pygoscelis", :species=>"Pygoscelis antarcticus", :object_class=>["extensibleObject", "aves"], :population_count=>10000, :extinct=>false, :endangered=>false, :study=>"ornithology"}, {:cn=>"Black Jumping Salamander", :order=>"Caudata", :family=>"Plethodontidae", :genus=>"Ixalotriton", :species=>"Ixalotriton niger", :object_class=>["extensibleObject", "amphibia"], :population_count=>2000, :extinct=>false, :endangered=>false}]>

create_animals.call(changeset)
# => [#<ROM::LDAP::Directory::Entry cn=Chinstrap Penguin,ou=animals,dc=rom,dc=ldap {"cn"=>["Chinstrap Penguin"], "endangered"=>["FALSE"], "extinct"=>["FALSE"], "family"=>["Spheniscidae"], "genus"=>["Pygoscelis"], "objectClass"=>["top", "extensibleObject", "aves"], "order"=>["Sphenisciformes"], "populationCount"=>["10000"], "species"=>["Pygoscelis antarcticus"], "study"=>["ornithology"]}>,
#     #<ROM::LDAP::Directory::Entry cn=Black Jumping Salamander,ou=animals,dc=rom,dc=ldap {"cn"=>["Black Jumping Salamander"], "endangered"=>["FALSE"], "extinct"=>["FALSE"], "family"=>["Plethodontidae"], "genus"=>["Ixalotriton"], "objectClass"=>["top", "amphibia", "extensibleObject"], "order"=>["Caudata"], "populationCount"=>["2000"], "species"=>["Ixalotriton niger"]}>]


animals.by_cn('Black Jumping Salamander').one[:endangered]
# => false

update_animal.by_cn('Black Jumping Salamander').call(endangered: true)
# => {:dn=>["cn=Black Jumping Salamander,ou=animals,dc=rom,dc=ldap"],
#     :cn=>["Black Jumping Salamander"],
#     :endangered=>true,
#     :extinct=>false,
#     :family=>"Plethodontidae",
#     :genus=>"Ixalotriton",
#     :object_class=>["top", "amphibia", "extensibleObject"],
#     :order=>"Caudata",
#     :population_count=>2000,
#     :species=>"Ixalotriton niger"}

animals.endangered.to_a

# changeset = animals.changeset(new_animals).associate()

delete_animal.by_cn('Chinstrap Penguin').call
# => #<ROM::LDAP::Directory::Entry cn=Chinstrap Penguin,ou=animals,dc=rom,dc=ldap {"cn"=>["Chinstrap Penguin"], "endangered"=>["FALSE"], "extinct"=>["FALSE"], "family"=>["Spheniscidae"], "genus"=>["Pygoscelis"], "objectClass"=>["top", "extensibleObject", "aves"], "order"=>["Sphenisciformes"], "populationCount"=>["10000"], "species"=>["Pygoscelis antarcticus"], "study"=>["ornithology"]}>

delete_animal.by_cn('Black Jumping Salamander').call
# => #<ROM::LDAP::Directory::Entry cn=Black Jumping Salamander,ou=animals,dc=rom,dc=ldap {"cn"=>["Black Jumping Salamander"], "endangered"=>["TRUE"], "extinct"=>["FALSE"], "family"=>["Plethodontidae"], "genus"=>["Ixalotriton"], "objectClass"=>["top", "amphibia", "extensibleObject"], "order"=>["Caudata"], "populationCount"=>["2000"], "species"=>["Ixalotriton niger"]}>

animals.whole_tree.search('(0.9.2342.19200300.100.1.1=admin)').first
# => #<ROM::LDAP::Directory::Entry cn=Leopard Gecko,ou=animals,dc=rom,dc=ldap {"cn"=>["Leopard Gecko"], "extinct"=>["FALSE"], "family"=>["Eublepharidae"], "genus"=>["Eublepharis"], "labeledURI"=>["https://en.wikipedia.org/wiki/Leopard_gecko"], "objectClass"=>["top", "reptilia", "extensibleObject"], "order"=>["Squamata"], "populationCount"=>["90000"], "species"=>["Eublepharis macularius"]}>


animals.with(auto_struct: false).matches(cn: '熊').to_a
# => [{:dn=>["cn=Giant Panda,ou=animals,dc=rom,dc=ldap"],
#      :cn=>["Giant Panda", "Cat Bear", "猫熊", "Bear Cat", "熊猫"],
#      :endangered=>true,
#      :extinct=>false,
#      :family=>"Ursidae",
#      :genus=>"Ailuropoda",
#      :labeled_uri=>["https://en.wikipedia.org/wiki/Giant_panda"],
#      :object_class=>["top", "mammalia", "extensibleObject"],
#      :order=>"Carnivora",
#      :population_count=>50,
#      :species=>"Ailuropoda melanoleuca",
#      :study=>:mammalogy}]

animals.schema.map(&:to_s)
# => [nil,
#     nil,
#     nil,
#     nil,
#     nil,
#     nil,
#     "description",
#     "discoveryDate",
#     nil,
#     "endangered",
#     "extinct",
#     "labeledURI",
#     "objectClass",
#     "populationCount"]

animals.schema.map(&:name)
# => [:cn,
#     :study,
#     :family,
#     :genus,
#     :order,
#     :species,
#     :description,
#     :discovery_date,
#     :dn,
#     :endangered,
#     :extinct,
#     :labeled_uri,
#     :object_class,
#     :population_count]

animals.limit(4).project(:cn, :object_class).to_a
# => [#<Entities::Animal cn=["Leopard Gecko"] object_class=["top", "reptilia", "extensibleObject"]>,
#     #<Entities::Animal cn=["Carpincho", "Capybara", "Water Pig"] object_class=["top", "mammalia", "extensibleObject"]>,
#     #<Entities::Animal cn=["Lion"] object_class=["top", "mammalia", "extensibleObject"]>,
#     #<Entities::Animal cn=["Dog", "Domestic Dog"] object_class=["top", "mammalia", "extensibleObject"]>]


animals.base # => "dc=rom,dc=ldap"

animals.whole_tree.base # => ""

animals.map(:cn).to_a
# => [["Leopard Gecko"],
#     ["Carpincho", "Capybara", "Water Pig"],
#     ["Lion"],
#     ["Dog", "Domestic Dog"],
#     ["Orangutan"],
#     ["Spur-thighed Tortoise"],
#     ["Poison Dart Frog"],
#     ["Koala", "Koala Bear"],
#     ["Elephant Shrew"],
#     ["Asian Elephant", "Asiatic Elephant"],
#     ["Giant Panda", "Cat Bear", "猫熊", "Bear Cat", "熊猫"],
#     ["Reef Manta Ray"],
#     ["Zebra", "Mountain Zebra"],
#     ["Turtle Frog"],
#     ["Megabat", "Sulawesi Fruit Bat", "Sulawesi Flying Fox"],
#     ["Killer Whale", "Orca"],
#     ["Platypus", "Duck-billed Platypus"],
#     ["James's Flamingo"],
#     ["Sun Bear", "Honey Bear"],
#     ["Human"],
#     ["Panther Chameleon"],
#     ["Red Fox"],
#     ["Dodo"],
#     ["Cat", "Domestic Cat"],
#     ["Common Newt"],
#     ["American Robin"]]

animals.dataset.directory.key_map.take(5).to_h
# => {:a_record=>"aRecord",
#     :access_control_subentries=>"accessControlSubentries",
#     :administrative_role=>"administrativeRole",
#     :ads_allow_anonymous_access=>"ads-allowAnonymousAccess",
#     :ads_authenticator_class=>"ads-authenticatorClass"}

# animals.rename(cn: :common_name).to_a

animals.where(objectclass: 'mammalia').find('Homo').count # => 0
animals.project(:species).where(object_class: 'mammalia').find('Homo').count # => 1
animals.where(objectClass: 'mammalia').find('Homo').count # => 0

animals.where(cn: 'human').one.species
# => "Homo sapiens"

animals.where { species.is 'homo sapiens' }.one.study
# => :anthropology

animals.where { population_count < 100 }.list(:species)
# => ["Hydrochoerus hydrochaeris",
#     "Pongo borneo",
#     "Testudo graeca",
#     "Dendrobates tinctorius",
#     "Phascolarctos cinereus",
#     "Ailuropoda melanoleuca",
#     "Equus zebra",
#     "Myobatrachus gouldii",
#     "Acerodon celebensis",
#     "Orcinus orca",
#     "Ornithorhynchus anatinus",
#     "Phoenicoparrus jamesi",
#     "Helarctos malayanus",
#     "Vulpes vulpes",
#     "Raphus cucullatus",
#     "Turdus migratorius"]

animals.where { `(cn=dodo)` }.count
# => 1

animals.matches(cn: 'hum').one
# => #<Entities::Animal cn=["Human"] study=:anthropology family="Hominidae" genus="Homo" order="Primates" species="Homo sapiens" description=["Modern humans are the only extant members of the subtribe Hominina, a branch of the tribe Hominini belonging to the family of great apes."] discovery_date=nil dn=["cn=Human,ou=animals,dc=rom,dc=ldap"] endangered=false extinct=false labeled_uri=["https://en.wikipedia.org/wiki/Human"] object_class=["top", "mammalia", "extensibleObject"] population_count=7582530942>

animals.equal(cn: 'orangutan').one.cn
# => ["Orangutan"]

animals.equal(cn: 'orangutan').one.common_name
# => "ORANGUTAN"

animals.where(extinct: true).to_a
# => [#<Entities::Animal cn=["Dodo"] study=nil family="Columbidae" genus="Raphus" order="Columbiformes" species="Raphus cucullatus" description=nil discovery_date=1598-01-01 00:00:00 UTC dn=["cn=Dodo,ou=extinct,ou=animals,dc=rom,dc=ldap"] endangered=nil extinct=true labeled_uri=nil object_class=["top", "aves", "extensibleObject"] population_count=0>]

animals.by_pk('cn=Lion,ou=animals,dc=rom,dc=ldap')
# => #<ROM::Relation[Animals] name=ROM::Relation::Name(animals on (species=*)) dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:con_and, [[:op_eql, :species, :wildcard], [:op_eql, :entry_dn, "cn=Lion,ou=animals,dc=rom,dc=ldap"]]]>>

animals.fetch('cn=Lion,ou=animals,dc=rom,dc=ldap')
# => #<Entities::Animal cn=["Lion"] study=:mammalogy family="Felidae" genus="Panthera" order="Carnivora" species="Panthera leo" description=nil discovery_date=nil dn=["cn=Lion,ou=animals,dc=rom,dc=ldap"] endangered=nil extinct=false labeled_uri=nil object_class=["top", "mammalia", "extensibleObject"] population_count=40000>

animals.list(:description).compact
# => ["Man's Best Friend",
#     "The King of the Swingers",
#     "Like all extant zebras, mountain zebras are boldly striped in black or dark brown and no two individuals look exactly alike.",
#     "They are frugivores and rely on their keen senses of sight and smell to locate food.",
#     "The genus name Orcinus means \"of the kingdom of the dead\", or \"belonging to Orcus\".",
#     "The Platypus is a semi-aquatic egg-laying mammal endemic to eastern Australia, including Tasmania.",
#     "It is one of the few species of venomous mammals; the male has a spur on the hind foot that delivers a venom capable of causing severe pain to humans.",
#     "The sun bear's fur is usually jet-black, short, and sleek with some under-wool; some individual sun bears are reddish or gray.",
#     "Modern humans are the only extant members of the subtribe Hominina, a branch of the tribe Hominini belonging to the family of great apes."]

animals.page(1).map(:cn).to_a
# => [["Leopard Gecko"],
#     ["Carpincho", "Capybara", "Water Pig"],
#     ["Lion"],
#     ["Dog", "Domestic Dog"],
#     ["Orangutan"],
#     ["Spur-thighed Tortoise"],
#     ["Poison Dart Frog"],
#     ["Koala", "Koala Bear"],
#     ["Elephant Shrew"],
#     ["Asian Elephant", "Asiatic Elephant"],
#     ["Giant Panda", "Cat Bear", "猫熊", "Bear Cat", "熊猫"],
#     ["Reef Manta Ray"],
#     ["Zebra", "Mountain Zebra"],
#     ["Turtle Frog"],
#     ["Megabat", "Sulawesi Fruit Bat", "Sulawesi Flying Fox"],
#     ["Killer Whale", "Orca"],
#     ["Platypus", "Duck-billed Platypus"],
#     ["James's Flamingo"],
#     ["Sun Bear", "Honey Bear"],
#     ["Human"],
#     ["Panther Chameleon"],
#     ["Red Fox"],
#     ["Dodo"],
#     ["Cat", "Domestic Cat"],
#     ["Common Newt"],
#     ["American Robin"]]

animals.per_page(6).page(2).map(:order).to_a
# => [["Squamata"],
#     ["Rodentia"],
#     ["Carnivora"],
#     ["Carnivora"],
#     ["Primates"],
#     ["Testudines"],
#     ["Anura"],
#     ["Diprotodontia"],
#     ["Macroscelidea"],
#     ["Proboscidea"],
#     ["Carnivora"],
#     ["Myliobatiformes"],
#     ["Perissodactyla"],
#     ["Anura"],
#     ["Chiroptera"],
#     ["Cetacea"],
#     ["Monotremata"],
#     ["Phoenicopteriformes"],
#     ["Carnivora"],
#     ["Primates"],
#     ["Squamata"],
#     ["Carnivora"],
#     ["Columbiformes"],
#     ["Carnivora"],
#     ["Caudata"],
#     ["Passeriformes"]]

animals.page(2).pager
# => #<ROM::LDAP::Plugin::Pagination::Pager dataset=#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]> options={:dataset=>#<ROM::LDAP::Dataset: base="dc=rom,dc=ldap" [:op_eql, :species, :wildcard]>, :current_page=>2, :per_page=>4}>

animals.page(2).pager.next_page
# => 3

animals.matches(cn: 'phant').count
# => 2

animals.matches(cn: 'domestic').to_a
# => [#<Entities::Animal cn=["Dog", "Domestic Dog"] study=:mammalogy family="Canidae" genus="Canis" order="Carnivora" species="Canis lupus" description=["Man's Best Friend"] discovery_date=nil dn=["cn=Dog,ou=animals,dc=rom,dc=ldap"] endangered=nil extinct=false labeled_uri=nil object_class=["top", "mammalia", "extensibleObject"] population_count=999090909>,
#     #<Entities::Animal cn=["Cat", "Domestic Cat"] study=:mammalogy family="Felidae" genus="Felis" order="Carnivora" species="Felis silvestris" description=nil discovery_date=nil dn=["cn=Cat,ou=animals,dc=rom,dc=ldap"] endangered=nil extinct=false labeled_uri=nil object_class=["top", "mammalia", "extensibleObject"] population_count=1234567689>]

animals.where(cn: 'megabat').map_with(:classification).to_a
# => [{:study=>:chiropterology,
#      :dn=>["cn=Sulawesi Fruit Bat,ou=animals,dc=rom,dc=ldap"],
#      :object_class=>["top", "mammalia", "extensibleObject"],
#      :taxonomy=>
#       {:species=>"Acerodon celebensis",
#        :order=>"Chiroptera",
#        :family=>"Pteropodidae",
#        :genus=>"Acerodon"},
#      :status=>{},
#      :info=>
#       {:labeled_uri=>["https://en.wikipedia.org/wiki/Sulawesi_flying_fox"],
#        :description=>
#         ["They are frugivores and rely on their keen senses of sight and smell to locate food."],
#        :cn=>["Megabat", "Sulawesi Fruit Bat", "Sulawesi Flying Fox"]}}]

repo.reptiles_to_yaml
# => "---\n- dn:\n  - cn=Panther Chameleon,ou=animals,dc=rom,dc=ldap\n  cn:\n  - Panther Chameleon\n  species:\n  - Furcifer pardalis\n- dn:\n  - cn=Leopard Gecko,ou=animals,dc=rom,dc=ldap\n  cn:\n  - Leopard Gecko\n  species:\n  - Eublepharis macularius\n- dn:\n  - cn=Spur-thighed Tortoise,ou=animals,dc=rom,dc=ldap\n  cn:\n  - Spur-thighed Tortoise\n  species:\n  - Testudo graeca\n"

repo.apes_to_ldif
# => "dn: cn=Orangutan,ou=animals,dc=rom,dc=ldap\ncn: Orangutan\ndescription: The King of the Swingers\nextinct: FALSE\nfamily: Hominidae\ngenus: Pongo\nobjectClass: top\nobjectClass: mammalia\nobjectClass: extensibleObject\norder: Primates\npopulationCount: 0\nspecies: Pongo borneo\nstudy: primatology\n\ndn: cn=Human,ou=animals,dc=rom,dc=ldap\ncn: Human\ndescription: Modern humans are the only extant members of the subtribe Hominina, a branch of the tribe Hominini belonging to the family of great apes.\nendangered: FALSE\nextinct: FALSE\nfamily: Hominidae\ngenus: Homo\nlabeledURI: https://en.wikipedia.org/wiki/Human\nobjectClass: top\nobjectClass: mammalia\nobjectClass: extensibleObject\norder: Primates\npopulationCount: 7582530942\nspecies: Homo sapiens\nstudy: anthropology\n\n"

repo.birds_to_json
# => "[{\"dn\":[\"cn=Dodo,ou=extinct,ou=animals,dc=rom,dc=ldap\"],\"cn\":[\"Dodo\"],\"species\":[\"Raphus cucullatus\"]},{\"dn\":[\"cn=James's Flamingo,ou=animals,dc=rom,dc=ldap\"],\"cn\":[\"James's Flamingo\"],\"species\":[\"Phoenicoparrus jamesi\"]},{\"dn\":[\"cn=American Robin,ou=animals,dc=rom,dc=ldap\"],\"cn\":[\"American Robin\"],\"species\":[\"Turdus migratorius\"]}]"


repo.mammals.to_a
# => [#<Entities::Animal cn=["Zebra", "Mountain Zebra"] description=["Like all extant zebras, mountain zebras are boldly striped in black or dark brown and no two individuals look exactly alike."] species="Equus zebra">,
#     #<Entities::Animal cn=["Carpincho", "Capybara", "Water Pig"] description=nil species="Hydrochoerus hydrochaeris">,
#     #<Entities::Animal cn=["Megabat", "Sulawesi Fruit Bat", "Sulawesi Flying Fox"] description=["They are frugivores and rely on their keen senses of sight and smell to locate food."] species="Acerodon celebensis">,
#     #<Entities::Animal cn=["Killer Whale", "Orca"] description=["The genus name Orcinus means \"of the kingdom of the dead\", or \"belonging to Orcus\"."] species="Orcinus orca">,
#     #<Entities::Animal cn=["Lion"] description=nil species="Panthera leo">,
#     #<Entities::Animal cn=["Dog", "Domestic Dog"] description=["Man's Best Friend"] species="Canis lupus">,
#     #<Entities::Animal cn=["Platypus", "Duck-billed Platypus"] description=["The Platypus is a semi-aquatic egg-laying mammal endemic to eastern Australia, including Tasmania.", "It is one of the few species of venomous mammals; the male has a spur on the hind foot that delivers a venom capable of causing severe pain to humans."] species="Ornithorhynchus anatinus">,
#     #<Entities::Animal cn=["Orangutan"] description=["The King of the Swingers"] species="Pongo borneo">,
#     #<Entities::Animal cn=["Sun Bear", "Honey Bear"] description=["The sun bear's fur is usually jet-black, short, and sleek with some under-wool; some individual sun bears are reddish or gray."] species="Helarctos malayanus">,
#     #<Entities::Animal cn=["Human"] description=["Modern humans are the only extant members of the subtribe Hominina, a branch of the tribe Hominini belonging to the family of great apes."] species="Homo sapiens">,
#     #<Entities::Animal cn=["Koala", "Koala Bear"] description=nil species="Phascolarctos cinereus">,
#     #<Entities::Animal cn=["Elephant Shrew"] description=nil species="Rhynchocyon petersi">,
#     #<Entities::Animal cn=["Asian Elephant", "Asiatic Elephant"] description=nil species="Elephas maximus">,
#     #<Entities::Animal cn=["Red Fox"] description=nil species="Vulpes vulpes">,
#     #<Entities::Animal cn=["Giant Panda", "Cat Bear", "猫熊", "Bear Cat", "熊猫"] description=nil species="Ailuropoda melanoleuca">,
#     #<Entities::Animal cn=["Cat", "Domestic Cat"] description=nil species="Felis silvestris">]


groups.wild_animals
# => ["cn=Red Fox, ou=animals, dc=rom, dc=ldap",
#     "cn=American Robin, ou=animals, dc=rom, dc=ldap",
#     "cn=Sun Bear, ou=animals, dc=rom, dc=ldap",
#     "cn=Zebra, ou=animals, dc=rom, dc=ldap",
#     "cn=Poison dart Frog, ou=animals, dc=rom, dc=ldap",
#     "cn=James's flamingo, ou=animals, dc=rom, dc=ldap",
#     "cn=Orangutan, ou=animals, dc=rom, dc=ldap",
#     "cn=Platypus, ou=animals, dc=rom, dc=ldap",
#     "cn=Sulawesi Fruit Bat, ou=animals, dc=rom, dc=ldap"]

groups.domestic_animals
# => ["cn=Spur-thighed Tortoise, ou=animals, dc=rom, dc=ldap",
#     "cn=Cat, ou=animals, dc=rom, dc=ldap",
#     "cn=Dog, ou=animals, dc=rom, dc=ldap"]
