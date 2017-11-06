require 'dry/core/constants'
require 'set'
require 'ber/refinements'

# Basic Encoding Rules
#
module BER
  include Dry::Core::Constants

  def self.refinements
    @refinements = (@refinements || Set.new) << BER
  end

  def self.function
    @func ||= Function.new
  end

  def self.root
    Pathname(File.dirname(__dir__))
  end

  def self.config
    Psych.load_file(root.join('lib/ber/config.yaml')).freeze
  end

  def self.reverse_lookup(type, symbol)
    config[type].key(symbol)
  end

  def self.lookup(type, int)
    config[type][int]
  end

  def self.compile_syntax(syntax)
    out = [nil] * 256

    syntax.each do |tag_class_id, encodings|
      tag_class = config[:tag_class][tag_class_id]
      encodings.each do |encoding_id, classes|
        encoding     = config[:encoding_type][encoding_id]
        object_class = tag_class + encoding
        classes.each do |number, object_type|
          out[object_class + number] = object_type
        end
      end
    end

    out
  end

  Error = Class.new(RuntimeError)
  Null  = BerIdentifiedNull.new

  ASN_SYNTAX       = compile_syntax(config[:syntax])
  BUILTIN_SYNTAX   = compile_syntax(config[:builtin_syntax])
  MAX_FIXNUM_SIZE  = 0.size
  WILDCARD         = '*'.freeze
  NEW_LINE         = "\n".freeze

end

require 'ber/pdu'
