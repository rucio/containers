#!/bin/sh
set -e


# Just in case this environment variable has gone missing.
HTTPD_PREFIX="${HTTPD_PREFIX:-/usr/local/apache2}"

# Configure vhosts.
if [ "x$SERVER_NAMES" != "x" ]; then
    # Use first domain as Apache ServerName.
    SERVER_NAME="${SERVER_NAMES%%,*}"
    sed -e "s|ServerName .*|ServerName $SERVER_NAME|" \
        -i "$HTTPD_PREFIX"/conf/sites-available/default*.conf

    # Replace commas with spaces and set as Apache ServerAlias.
    SERVER_ALIAS="`printf '%s\n' "$SERVER_NAMES" | tr ',' ' '`"
    sed -e "/ServerName/a\ \ ServerAlias $SERVER_ALIAS" \
        -i "$HTTPD_PREFIX"/conf/sites-available/default*.conf
fi

# Configure dav.conf
if [ "x$LOCATION" != "x" ]; then
    sed -e "s|Alias .*|Alias $LOCATION /var/lib/dav/data/|" \
        -i "$HTTPD_PREFIX/conf/conf-available/dav.conf"
fi
if [ "x$REALM" != "x" ]; then
    sed -e "s|AuthName .*|AuthName \"$REALM\"|" \
        -i "$HTTPD_PREFIX/conf/conf-available/dav.conf"
else
    REALM="WebDAV"
fi
if [ "x$AUTH_TYPE" != "x" ]; then
    # Only support "Basic" and "Digest".
    if [ "$AUTH_TYPE" != "Basic" ] && [ "$AUTH_TYPE" != "Digest" ]; then
        printf '%s\n' "$AUTH_TYPE: Unknown AuthType" 1>&2
        exit 1
    fi
    sed -e "s|AuthType .*|AuthType $AUTH_TYPE|" \
        -i "$HTTPD_PREFIX/conf/conf-available/dav.conf"
fi

# This will either be the self-signed certificate generated above or one that
# has been bind mounted in by the user.
if [ -e /privkey.pem ] && [ -e /cert.pem ]; then
    # Enable SSL Apache modules.
    for i in http2 ssl; do
        sed -e "/^#LoadModule ${i}_module.*/s/^#//" \
            -i "$HTTPD_PREFIX/conf/httpd.conf"
    done
    # Enable SSL vhost.
    ln -sf ../sites-available/default-ssl.conf \
        "$HTTPD_PREFIX/conf/sites-enabled"
fi

# Create directories for Dav data and lock database.
[ ! -d "/var/lib/dav/data" ] && mkdir -p "/var/lib/dav/data"
[ ! -d "/var/lib/dav/data/rucio" ] && mkdir -p "/var/lib/dav/data/rucio"
[ ! -e "/var/lib/dav/DavLock" ] && touch "/var/lib/dav/DavLock"
chown -R www-data:www-data "/var/lib/dav"

exec "$@"
