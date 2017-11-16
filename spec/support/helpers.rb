module Helpers

  def use_formatter(formatter)
    ROM::LDAP::Directory::Entity.use_formatter(formatter)
  end

end
