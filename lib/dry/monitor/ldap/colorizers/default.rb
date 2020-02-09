# frozen_string_literal: true

module Dry
  module Monitor
    module LDAP
      module Colorizers
        class Default
          def initialize(_theme); end

          def call(string)
            string
          end
        end
      end
    end
  end
end
