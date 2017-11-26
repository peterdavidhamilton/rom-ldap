module Helpers

  def use_formatter(formatter)
    ROM::LDAP::Directory::Entry.use_formatter(formatter)
  end

  def reload_attributes!
    relations[:accounts].dataset.directory.attribute_types
  end

  def reset_attributes!
    ROM::LDAP::Directory.attributes = nil
  end

  def password_generate(passwd)
    ROM::LDAP::Directory::Password.generate(:sha, passwd)
  end
end
