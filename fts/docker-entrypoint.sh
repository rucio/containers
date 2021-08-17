#!/bin/bash

# wait for MySQL readiness
/usr/local/bin/wait-for-it.sh -h ftsdb -p 3306 -t 3600

# initialise / upgrade the database
/usr/share/fts/fts-database-upgrade.py <<< y

# fix Apache configuration
/usr/bin/sed -i 's/Listen 80/#Listen 80/g' /etc/httpd/conf/httpd.conf

# startup the FTS services
/usr/sbin/fts_server               # main FTS server daemonizes
/usr/sbin/fts_msg_bulk             # daemon to send messages to activemq
/usr/sbin/fts_bringonline          # daemon to handle staging requests
/usr/sbin/httpd -DFOREGROUND       # FTS REST frontend & FTSMON
