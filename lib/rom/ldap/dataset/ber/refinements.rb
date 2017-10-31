require_relative 'basic_encoding_rules'

require_relative 'refinements/string'
require_relative 'refinements/array'
require_relative 'refinements/integer'
require_relative 'refinements/true_class'
require_relative 'refinements/false_class'

class IO
  include ::BasicEncodingRules
end

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
    include ::BasicEncodingRules
  end #if defined? ::OpenSSL

  refine IO do
    # include ::BasicEncodingRules


    # extend ::BasicEncodingRules

    # def self.used(mod)
    #   binding.pry
    #   mod.send(:include, ::BasicEncodingRules)
    #   # mod.send(:extend, ::BasicEncodingRules)
    # end


    def self.used(mod)
      mod.send(:using, ::BasicEncodingRules)
    end

    # def self.included(mod)
    #   binding.pry
    #   mod.send(:using, ::BasicEncodingRules)
    # end
  end

  refine StringIO do
    # include ::BasicEncodingRules
    # def self.used(mod)
    #   mod.send(:include, ::BasicEncodingRules)
    # end
    def self.included(mod)
      mod.send(:include, ::BasicEncodingRules)
    end
  end



  # refine IO.singleton_class do
  #   include ::BasicEncodingRules
  # end

  # refine StringIO.singleton_class do
  #   include ::BasicEncodingRules
  # end

end

