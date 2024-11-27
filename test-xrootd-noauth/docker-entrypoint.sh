#!/bin/bash

echo "xrd.port $XRDPORT" >> /etc/xrootd/xrdrucio.cfg
echo '======== /etc/xrootd/xrdrucio.cfg ========'
cat /etc/xrootd/xrdrucio.cfg
echo '=========================================='

echo 'Fixing ownership and permissions'
cp /tmp/xrdcert.pem /etc/grid-security/xrd/xrdcert.pem
cp /tmp/xrdkey.pem /etc/grid-security/xrd/xrdkey.pem
chown -R xrootd:xrootd /etc/grid-security/xrd
chmod 0400 /etc/grid-security/xrd/xrdkey.pem

xrootd -R xrootd -n rucio -c /etc/xrootd/xrdrucio.cfg
