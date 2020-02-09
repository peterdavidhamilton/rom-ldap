
# @example uri_for('apache_ds') => "ldap://apacheds:10389"
#
# @return [String]
def uri_for(vendor_name = nil)
  vendor_name ||= 'apache_ds'
  HOSTS[vendor_name][source]
end

# @return [Integer]
def source
  case
  when  docker? && !ssl then 0
  when  docker? &&  ssl then 1
  when !docker? && !ssl then 2
  when !docker? &&  ssl then 3
  end
end


# @return [TrueClass, FalseClass]
def docker?
  `ls -ali / | sed '2!d' | awk {'print $1'}`.to_i > 2
end

#
#
def with_vendors(*args, &block)
  vendors = args.empty? ? HOSTS.keys : args

  vendors.each do |vendor|
    context("with #{vendor}") do
      include_context('vendor', vendor, &block)
    end
  end
end
