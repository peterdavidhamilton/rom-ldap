module ROM
  module LDAP
    # LDAPv3 Syntaxes
    # @see https://ldapwiki.com/wiki/LDAPSyntaxes
    #
    OID_TYPE_MAP = {
      '1.3.6.1.1.16.1'                =>  'String',     # UUID
      '1.3.6.1.4.1.1466.115.121.1.1'  =>  'String',     # ACI Item
      '1.3.6.1.4.1.1466.115.121.1.2'  =>  'String',     # Access Point
      '1.3.6.1.4.1.1466.115.121.1.3'  =>  'String',     # Attribute Type Description
      '1.3.6.1.4.1.1466.115.121.1.4'  =>  'Binary',     # Audio
      '1.3.6.1.4.1.1466.115.121.1.5'  =>  'Binary',     # Binary
      '1.3.6.1.4.1.1466.115.121.1.6'  =>  'String',     # Bit String
      '1.3.6.1.4.1.1466.115.121.1.7'  =>  'Bool',       # Boolean
      '1.3.6.1.4.1.1466.115.121.1.8'  =>  'String',     # Certificate
      '1.3.6.1.4.1.1466.115.121.1.9'  =>  'String',     # Certificate List
      '1.3.6.1.4.1.1466.115.121.1.10' =>  'String',     # Certificate Pair
      '1.3.6.1.4.1.1466.115.121.1.11' =>  'String',     # Country String - IA5 ISO-646 (ASCII). Limited to exactly two characters describing the ISO 3166 country code.
      '1.3.6.1.4.1.1466.115.121.1.12' =>  'String',     # DN
      '1.3.6.1.4.1.1466.115.121.1.13' =>  'String',     # Data Quality Syntax
      '1.3.6.1.4.1.1466.115.121.1.14' =>  'String',     # Delivery Method
      '1.3.6.1.4.1.1466.115.121.1.15' =>  'String',     # Directory String
      '1.3.6.1.4.1.1466.115.121.1.19' =>  'String',     # DSA Quality Syntax
      '1.3.6.1.4.1.1466.115.121.1.20' =>  'String',     # DSE Type
      '1.3.6.1.4.1.1466.115.121.1.21' =>  'String',     # Enhanced Guide
      '1.3.6.1.4.1.1466.115.121.1.22' =>  'String',     # Facsimile Telephone Number
      '1.3.6.1.4.1.1466.115.121.1.23' =>  'String',     # Fax
      '1.3.6.1.4.1.1466.115.121.1.24' =>  'Time',       # Generalized Time
      '1.3.6.1.4.1.1466.115.121.1.25' =>  'String',     # Guide
      '1.3.6.1.4.1.1466.115.121.1.26' =>  'String',     # IA5String - IA5 ISO-646 (ASCII).
      '1.3.6.1.4.1.1466.115.121.1.27' =>  'Integer',    # INTEGER - IntegerMatch / integerOrderingMatch
      '1.3.6.1.4.1.1466.115.121.1.28' =>  'Binary',     # JPEG - RFC2798: Joint Photographic Experts Group (JPEG) image syntax from inetOrgPerson object class schema.
      '1.3.6.1.4.1.1466.115.121.1.32' =>  'String',     # Mail Preference
      '1.3.6.1.4.1.1466.115.121.1.34' =>  'String',     # Name And Optional UID
      '1.3.6.1.4.1.1466.115.121.1.35' =>  'String',     # Name Form Description
      '1.3.6.1.4.1.1466.115.121.1.36' =>  'Integer',    # Numeric String - IA5 ISO-646 (ASCII).
      '1.3.6.1.4.1.1466.115.121.1.37' =>  'String',     # Object Class Description
      '1.3.6.1.4.1.1466.115.121.1.38' =>  'String',     # OID
      '1.3.6.1.4.1.1466.115.121.1.39' =>  'String',     # Other Mailbox
      '1.3.6.1.4.1.1466.115.121.1.40' =>  'String',     # Octet String - Treated as transparent 8-bit bytes. (passwords)
      '1.3.6.1.4.1.1466.115.121.1.41' =>  'String',     # Postal Address - UTF-8 ISO-10646 (Unicode). Split by dollar sign "$".
      '1.3.6.1.4.1.1466.115.121.1.42' =>  'String',     # Protocol Information
      '1.3.6.1.4.1.1466.115.121.1.43' =>  'String',     # Presentation Address
      '1.3.6.1.4.1.1466.115.121.1.44' =>  'String',     # Printable String
      '1.3.6.1.4.1.1466.115.121.1.50' =>  'String',     # Telephone Number
      '1.3.6.1.4.1.1466.115.121.1.51' =>  'String',     # Teletex Terminal Identifier
      '1.3.6.1.4.1.1466.115.121.1.52' =>  'String',     # Telex Number
      '1.3.6.1.4.1.1466.115.121.1.53' =>  'Time',       # UTC Time
      '1.3.6.1.4.1.1466.115.121.1.54' =>  'String',     # LDAP Syntax Description
      '1.3.6.1.4.1.1466.115.121.1.56' =>  'String',     # LDAP Schema Definition
      '1.3.6.1.4.1.1466.115.121.1.57' =>  'String',     # LDAP Schema Description

      # Microsoft Active Directory
      #
      # @see https://ldapwiki.com/wiki/Microsoft%20Active%20Directory%20Syntax
      # @see https://docs.microsoft.com/en-gb/windows/desktop/ADSchema/attributes-all
      # @see https://docs.microsoft.com/en-us/windows/desktop/ADSI/data-type-mapping-between-active-directory-and-ldap
      #
      '1.2.840.113556.1.2.19'         =>  'Time',       # uSNCreated
      '1.2.840.113556.1.2.120'        =>  'Time',       # uSNChanged

      '1.2.840.113556.1.4.49'         =>  'Time',       # badPasswordTime
      '1.2.840.113556.1.4.52'         =>  'Time',       # lastLogon
      '1.2.840.113556.1.4.53'         =>  'Time',       # lastSetTime
      '1.2.840.113556.1.4.60'         =>  'Time',       # lockoutDuration
      '1.2.840.113556.1.4.74'         =>  'Time',       # maxPwdAge
      '1.2.840.113556.1.4.76'         =>  'Integer',    # maxStorage
      '1.2.840.113556.1.4.78'         =>  'Time',       # minPwdAge
      '1.2.840.113556.1.4.96'         =>  'Time',       # pwdLastSet
      '1.2.840.113556.1.4.159'        =>  'Time',       # accountExpires
      '1.2.840.113556.1.4.371'        =>  'Integer',    # rIDAllocationPool
      '1.2.840.113556.1.4.662'        =>  'Time',       # lockoutTime
      '1.2.840.113556.1.4.903'        =>  'String',     # DNWithOctetString
      '1.2.840.113556.1.4.904'        =>  'String',     # DNWithString
      '1.2.840.113556.1.4.905'        =>  'String',     # Telex
      '1.2.840.113556.1.4.906'        =>  'Integer',    # INTEGER8
      '1.2.840.113556.1.4.907'        =>  'String',     # ObjectSecurityDescriptor
      '1.2.840.113556.1.4.1221'       =>  'String',     # CaseIgnoreString' / ORName
      '1.2.840.113556.1.4.1362'       =>  'String',     # CaseExactString
      '1.2.840.113556.1.4.1696'       =>  'Time'        # lastLogonTimeStamp
    }.freeze
  end
end
