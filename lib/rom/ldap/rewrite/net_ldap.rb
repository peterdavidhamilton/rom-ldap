# NB: Gradually replace unwanted Net::LDAP code

# Dependencies
require 'ostruct'
require 'socket'
# require 'openssl'


require 'net/ber'
require 'net/ldap/pdu'
require 'net/ldap/filter'
require 'net/ldap/dataset'
require 'net/ldap/password'
require 'net/ldap/entry'
require 'net/ldap/instrumentation'
require 'net/ldap/connection'
require 'net/ldap/error'



require 'net/ldap/auth_adapter'

require 'net/ldap/auth_adapter/simple'
Net::LDAP::AuthAdapter.register([:simple, :anon, :anonymous], Net::LDAP::AuthAdapter::Simple)

require 'net/ldap/auth_adapter/sasl'
Net::LDAP::AuthAdapter.register(:sasl, Net::LDAP::AuthAdapter::Sasl)

