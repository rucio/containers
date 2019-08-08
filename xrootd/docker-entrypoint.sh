#!/bin/bash

echo "xrd.port $XRDPORT" >> /etc/xrootd/xrdrucio.cfg

echo '======== /etc/xrootd/xrdrucio.cfg ========'
cat /etc/xrootd/xrdrucio.cfg
echo '=========================================='

xrootd -d -R xrootd -c /etc/xrootd/xrdrucio.cfg
