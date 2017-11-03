# TODO: move BER refinements up out of the ROM namespace.
#
require 'rom/ldap/ber/instance_methods'

require 'rom/ldap/ber/refinements/string'
require 'rom/ldap/ber/refinements/array'
require 'rom/ldap/ber/refinements/integer'
require 'rom/ldap/ber/refinements/true_class'
require 'rom/ldap/ber/refinements/false_class'

module BER

  # use for debugging refinements
  def refinements
    require 'set'
    @refinements = (@refinements || Set.new) << BER
  end


  refine OpenSSL::SSL::SSLSocket do
    # def self.used(mod)
    #   mod.send(:include, ::BasicEncodingRules)
    # end
    # include ::ROM::LDAP::BER::InstanceMethods
  end #if defined? ::OpenSSL


  # Pass a single logic into each reifined object to handle the logic?
  def rule_logic
    @rule_logic ||= RuleLogic.new
  end


  refine IO do
    def read_ber(syntax = nil)
      rule_logic.read_ber(syntax)
    end

    def read_ber_length
      rule_logic.read_ber_length(self)
    end

    def parse_ber_object(syntax, id, data)
      rule_logic.parse_ber_object(self, syntax, id, data)
    end



    # include ::ROM::LDAP::BER::InstanceMethods

    # def self.used(mod)
    #   mod.send(:using, ::ROM::LDAP::BER::InstanceMethods)
    # end
    # def self.included(mod)
    #   mod.send(:using, ::ROM::LDAP::BER::InstanceMethods)
    # end
  end

  refine StringIO do
    def read_ber(syntax = nil)
    end

    def read_ber_length
    end

    def parse_ber_object(syntax, id, data)
    end
  end


  refine IO.singleton_class do
    # include ::ROM::LDAP::BER::InstanceMethods
    # def self.used(mod)
    #   mod.send(:include, ::ROM::LDAP::BER::InstanceMethods)
    # end
    # def self.included(mod)
    #   mod.send(:include, ::ROM::LDAP::BER::InstanceMethods)
    # end
  end

end

