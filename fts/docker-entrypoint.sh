#!/bin/bash

# wait for MySQL readiness
/usr/local/bin/wait-for-it.sh -h ftsdb -p 3306 -t 3600

# initialise / upgrade the database
mysql -h ftsdb -u fts --password=fts fts < $(ls /usr/share/fts-mysql/fts-schema* | sort -t '-' -k '4n' | tail -n 1)
# TODO: go back to using this script once the fixed it and bundled with the new fts version:
# /usr/share/fts/fts-database-upgrade.py -y

# fix Apache configuration
/usr/bin/sed -i 's/Listen 80/#Listen 80/g' /etc/httpd/conf/httpd.conf
cp /opt/rh/httpd24/root/usr/lib64/httpd/modules/mod_rh-python36-wsgi.so /lib64/httpd/modules
cp /opt/rh/httpd24/root/etc/httpd/conf.modules.d/10-rh-python36-wsgi.conf /etc/httpd/conf.modules.d

# startup the FTS services
/usr/sbin/fts_server               # main FTS server daemonizes
/usr/sbin/fts_msg_bulk             # daemon to send messages to activemq
/usr/sbin/fts_bringonline          # daemon to handle staging requests
/usr/sbin/httpd -DFOREGROUND       # FTS REST frontend & FTSMON
