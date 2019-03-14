
# config templating

LDAP_ADMIN_PASSWORD_ENCRYPTED=$(slappasswd -s "$LDAP_ADMIN_PASSWORD")
sed -i "s|{{ LDAP_ADMIN_PASSWORD_ENCRYPTED }}|${LDAP_ADMIN_PASSWORD_ENCRYPTED}|g" /ldif/admin-pw-change.ldif
sed -i "s|{{ LDAP_BASE_DN }}|${LDAP_BASE_DN}|g" /ldif/admin-pw-change.ldif

ldapmodify -Y EXTERNAL -Q -H ldapi:/// -f /ldif/admin-pw-change.ldif
