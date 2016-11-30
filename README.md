#
# Plan ROM commands
# -----------------



add_ldap_image(
dn: 'uid=test0,ou=users,dc=test',
url: 'https://avatars2.githubusercontent.com/u/795488?v=3&s=52'
)


# Chainable method interface
#     relation read methods just build filters
#     filters are then chained together and summed
#     where / match / not / starts_with

# class Relation[:people]
class Relation
  extend Forwardable

  # attr_accessor :chain

    class Query
      extend Forwardable
      def initialize(*)
        @chain  = Hashie::Clash.new
        @ldap   = Toolbox::Container['directory.ldap']
      end

      def_delegators :@chain, :where, :match, :not, :starts_with

      def call
        # @ldap.search(filter: "(&#{filters.join})")
        # system "say #{filters}"
        puts filters
      end

      # alias :[], :call

      def filters
        # binding.pry
        @chain.each_with_object([]) do |(method, params), collection|
          # collection << send(method, params)
          collection << method
          collection << params
        end
      end
    end


  # class accessible object
  # Relation.query
  class << self
    attr_accessor :query
  end

  def initialize(*)
    self.class.query = Query.new
    @query = self.class.query
  end

  # Relation.new.search runs == Query.new.call from Relation.query
  # def_delegator :@dataset, :call, :search
  def_delegator :@query, :call, :search

  # def search
  #   __new__ Dataset.new
  # end
  # new relation containing search results of chained filter
  # def search
  #   # __new__ directory.search("(&#{chain.join})")
  #   @ldap.search(filter: "(&#{filters.join})")
  # end

end

people = Relation.new
people.search.where(sn: 'hamilton', title: 'mr').match(givenname: 'ete').not(uid: 'hamilt09').order(:sn)

# or

people.search Query.new.where(sn: 'hamilton', title: 'mr')

# Chainable arguments for searching
# dataset = Relation.new
# dataset.where(sn: 'hamilton', title: 'mr').match(givenname: 'ete').not(uid: 'hamilt09').order(:sn)
# dataset.search


class Repo
  def cool_query
    people.search
      .where(sn: 'hamilton', title: 'mr')
      .match(givenname: 'ete')
      .not(uid: 'hamilt09')
      .order(:sn)
  end
end

people = Relation.new
people.search.where(sn: 'hamilton', title: 'mr').match(givenname: 'ete').not(uid: 'hamilt09').order(:sn)

# {
#   where: { sn: 'hamilton', title: 'mr'   },
#   match: { givenname: 'ete' },
#     not: { uid: 'hamilt09'  },
#   order: :sn
# }

filters = @chain.each_with_object([]) do |(method, params), collection|
  collection << send(method, params)
end

# filters = [
#   where(sn: 'hamilton', title: 'mr')  # Net::LDAP::Filter
#   match(givenname: 'ete')             # Net::LDAP::Filter
#   not(uid: 'hamilt09')           # Net::LDAP::Filter
# ]

__new__ search("(&#{filters.join})")



                                      # where                   match               not
Net::LDAP::Filter.construct "(& (&(sn=hamilton)(title=mr))  (givenname=*ete*)  (!(uid=hamilt09))  )"


def this_not_that(this, that)
  dataset.where(this).not(that)
end

this_not_that {sn: 'hamilton'}, {uid: 'hamilt09'}









class Query < Hashie::Clash
  def where(args)
    "(uid=*)"
  end

  def not(args)
    "(uid=*)"
  end

  def match(args)
    "(uid=*)"
  end

  def starts_with(args)
    "(uid=*)"
  end

  def order(args)
    "(uid=*)"
  end
end



class Relation
  extend Forwardable

  def initialize(*)
    @query = Query.new
  end

  attr_accessor :query

  # def_delegators :@query, :where, :match, :not, :starts_with

  def new
    construct "(&#{filters.join})"
  end

  def filters
    @query.each_with_object([]) do |(method, params), collection|
      collection << send(method, params)
    end
  end

  def construct(term)
    Net::LDAP::Filter.construct(term)
  end

  def search(query)
    Toolbox::Container['directory.ldap'].search(filter: query)
  end

end


people = Relation.new
people.search people.query.where(sn: 'hamilton', title: 'mr').match(givenname: 'ete').not(uid: 'hamilt09').order(:sn)


ldap = Toolbox::Container['directory.ldap']
config = Toolbox::Container['config']

# sorted hash just for ldap
ldap_config = config.to_h.select { |k,v| k['ldap'] }.sort.to_h

# CREATE

# minimal user
new_user      = OpenStruct.new
new_user.cn   = 'leanda'
new_user.uid  = 'leanda'
new_user.sn   = 'johnson'

@ldap = Toolbox::Container['directory.ldap']

def save_user(user)
  dn   = "uid=#{user.uid},ou=users,dc=test"
  user.objectclass = ['top', 'inetorgperson', 'person']
  @ldap.add(dn: dn, attributes: user.to_h)
end

@ldap.get_operation_result

ldap.add  dn: 'uid=temp,ou=users,dc=test',
  attributes: {
    objectclass: ['top', 'inetorgperson', 'person'],
    uid: 'temp_user',
    cn: 'New User',
    sn: 'test guy'
  }

ldap.get_operation_result

# NEW

entry = Net::LDAP::Entry.new
entry[:dn] = 'uid=example,ou=users,dc=test'


# UPDATE

ldap.delete_attribute 'uid=diradmin,ou=users,dc=test', :mail

ldap.add_attribute 'uid=diradmin,ou=users,dc=test', :mail, 'test@thing.com'

ldap.replace_attribute dn, :mail, "newmailaddress@example.com"

dn = "uid=example,ou=users,dc=test"
ops = [
  [:add, :mail, "aliasaddress@example.com"],
  [:replace, :mail, ["newaddress@example.com", "newalias@example.com"]],
  [:delete, :sn, nil] # sn attribute must exist
]

ldap.modify dn: dn, operations: ops



# binary attachments work if utf-8 strings
# could do a lookup by uid instead
def add_image(dn, url)

  file = ->(url) do
    processor = Toolbox::Container['assets.processor']

    case url.split(':').first
    when 'http'  then processor.fetch_url(url)
    when 'https' then processor.fetch_url(url)
    when 'file'  then processor.fetch_file(url)
    else
      raise 'Unknown url'
    end
  end

  payload = file[url].encode('jpg').data.force_encoding('utf-8')

  @ldap.replace_attribute dn, :jpegphoto, payload
end

# example using a PNG
add_image 'uid=test1,ou=users,dc=test', 'http://vignette4.wikia.nocookie.net/robber-penguin-agency/images/6/6e/Small-mario.png/revision/latest?cb=20150107080404'



# DELETE
ldap.delete dn: 'uid=temp,ou=users,dc=test'

# READ

# listing
ldap.search(filter: Net::LDAP::Filter.pres('uid'))

# by_uid(uid)
ldap.search(filter: Net::LDAP::Filter.eq('uid', uid))

# by_mail(mail)
ldap.search(filter: Net::LDAP::Filter.eq('mail', mail))

# where(key, value)
ldap.search(filter: Net::LDAP::Filter.eq(key.to_s, value))



def where_not(key, value)
  @ldap.search(filter: ~ Net::LDAP::Filter.eq(key.to_s, value))
end


# export
where_not(:mail, 'tits').first.to_ldif
# Net::LDAP::Dataset.to_ldif


# @example
#   import './config/users.ldif'
#
def import(file)
       io = File.open(file)
  dataset = Net::LDAP::Dataset.read_ldif(io)
  dataset.to_entries
  # dataset.each { |entry| add(entry) }
  # dataset.each { |entry| add(entry[0], entry[1]) }
  # puts dataset.map(&:first)
  dataset.to_entries.map(&:dn)
end

def add(dn, attributes)
  @ldap.add(dn: dn, attributes: attributes)
end

# check the uid is present
def exists?(uid)
  !@ldap.search(filter: uid_equals(uid)).empty?
end

# end point
def search(filter)
  @ldap.search(filter: filter)
end


def construct(query)
  Net::LDAP::Filter.construct(query)
end







# @example
#   where(uid: 'test', sn: 'Administrator')
#
def where(args = {})
  return false if args.empty?
  filters = []

  args.each do |key, value|
    filters.push construct("(#{key}=#{value})")
  end

    binding.pry
  search "(&#{*filters})"
  # FIXME: join array of filters
  # search filters.map(&:join)
end









# "(uid=test)"
def uid_equals(uid)
  Net::LDAP::Filter.eq('uid', uid)
end

default_dataset = ldap.search(filter: Net::LDAP::Filter.eq('uid', uid))

# convert each Net::LDAP::Entry to a hash without monkeypatching
dataset.map(&->(entry) { entry.instance_variable_get(:@myhash) })

# or

def entries_to_hashes(array)
  array.map(&->(entry){entry.instance_variable_get(:@myhash)} )
end

entries_to_hashes(dataset)

# only some attributes
ldap.search(filter: Net::LDAP::Filter.pres('uid'), attributes: ['cn', 'sn'])


# array of common names
# @ldap.search(filter: Net::LDAP::Filter.pres('uid'), attributes: ['cn', 'sn']).map(&:cn).flatten
@ldap.search(filter: Net::LDAP::Filter.pres('uid')).map(&:cn).flatten

def order
  order_by(:cn) # or
  # order_by('sn')
end

# order dataset by cn
def order_by(attribute)
  # dataset = @ldap.search(filter: Net::LDAP::Filter.pres('uid'))
  dataset.sort { |p1, p2| p1[attribute] <=> p2[attribute] }
end




relation = OpenStruct.new(complex_filter: 'filter', search: 'search')
lookup   = Lookup.new(relation)

# chainable query interface for ldap inspired by Hashie::Clash with lazy loading mechanism

lookup.match(mail: 'hotmail.com')
lookup.present(:jpegphoto)
lookup.exclude(groupid: [1, 2 ,3])
lookup.where(givenname: 'tom', 'apple-mcxsettings': { app_plist: '<xml></xml>' })
lookup.order(:uid)
# lookup.search!


require 'dry-initializer'
require 'uber/delegates'

class Lookup < ::Hash

  extend ::Dry::Initializer::Mixin
  extend ::Uber::Delegates

  param     :relation
  delegates :relation, :complex_filter, :search

  # def each(&block)
  # def to_a
  def search!
    # puts "#{search} #{complex_filter} #{self.to_s}"
    search complex_filter(self)
  end

  # complex_filter needs to raise when an un-implemented query method is used
  # escape
  # unescape
  # coalesce
  # match
  # execute
  # exclude
  # match
  # not
  # order  - needs to be fired last!!
  # present
  # where

  def chain(key, *args)
    self[key] = args.one? ? args.first : args
    self
  end

  def method_missing(name, *args)
    args.any? ? chain(name, *args) : super
  end

  # hijack mapper to call search automatically
  def as(mapper)
    # dataset = search complex_filter(self)
    # relation.class.new(dataset).as(mapper)
    search!.as(mapper)
  end

  # hijack when turning relation to array
  # def to_a
  #   search complex_filter(self)
  #   search!
  # end

  # alias :search! :to_a
  alias :to_a :search!
end



class Repo
  def public_method
    relations.people_with_similar_names_who_dont_use_hotmail(1,2,3).as(User).to_a
  end
end



class Relation
  # 'jam', 'ith', ['c12345', 'c23467']
  def people_with_similar_names_who_dont_use_hotmail(first, last, ids)
    lookup
      .match(givenname: first, sn: last)
      .exclude(mail: 'hotmail.com')
      .not(uid: ids)
      # .search!
  end

  def twenty_something_threesomes
    lookup
      .where(givenname: ['rita', 'sue', 'bob'])   # multi value
      # .lower(age: 21)                           # lower than
      .between(age: 20..30)                       # range
      .order(:age)
      # .search!
  end

#  FilterTypes = [:ne, :eq, :ge, :le, :and, :or, :not, :ex, :bineq]

  def within_filter(range)
    upper = range.to_a.last
    upper = range.to_a.first

  end

  def within(args = {})
    filter  = within_filter(args)
    dataset = search(filter)
    __new__(dataset)
  end

  alias :between :within

  # greater than or equal
  def above(int?)

  end

  # less than or equal
  def below(int?)

  end

end


