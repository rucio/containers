#!/bin/bash

set -e -o pipefail

# wait for MySQL readiness
/usr/local/bin/wait-for-it.sh -h ftsdb -p 3306 -t 3600

# initialise / upgrade the database
/usr/share/fts/fts-database-upgrade.py -y

# startup the FTS services
/usr/sbin/fts_server               # main FTS server daemonizes
/usr/sbin/fts_msg_bulk             # daemon to send messages to activemq
/usr/sbin/fts_qos                  # daemon to handle staging requests
exec /usr/sbin/httpd -DFOREGROUND       # FTS REST frontend & FTSMON
