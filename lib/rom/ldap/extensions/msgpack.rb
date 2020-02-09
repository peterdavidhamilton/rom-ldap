require 'msgpack'

module ROM
  module LDAP
    module MsgPackExport
      # Export the relation as MessagePack Binary
      #
      # @return [String]
      #
      # @example
      #   relation.to_msgpack
      #
      # @api public
      def to_msgpack
        export.to_msgpack
      end
    end

    Relation.include MsgPackExport
  end
end
