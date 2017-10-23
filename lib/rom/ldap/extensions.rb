require 'dry/core/extensions'

module ROM
	module LDAP
		extend Dry::Core::Extensions

		register_extension(:active_directory) do
			require 'rom/sql/extensions/active_directory'
		end

  end
end
