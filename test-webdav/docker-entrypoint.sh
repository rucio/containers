#!/bin/sh
set -e

. /etc/apache2/envvars

# Certificates have been mounted by the user.
a2dismod zgridsite
if [ -e /etc/grid-security/hostcert.pem ] && [ -e /etc/grid-security/hostkey.pem ]; then
  a2ensite default-ssl
else
  a2dissite default
fi

exec "$@"
