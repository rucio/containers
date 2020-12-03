#!/bin/sh

if [ -f /opt/rucio/etc/rucio.cfg ]; then
    echo "rucio.cfg already mounted."
else
    echo "rucio.cfg not found. will generate one."
    j2 --customize=/tmp/j2cfg.py /tmp/rucio.cfg.j2 > /opt/rucio/etc/rucio.cfg
fi

if [ ! -z "$RUCIO_PRINT_CFG" ]; then
    echo "=================== /opt/rucio/etc/rucio.cfg ============================"
    cat /opt/rucio/etc/rucio.cfg
    echo ""
fi

/usr/bin/memcached -u memcached -p 11211 -m 64 -c 1024 &

if [ "$RUCIO_DAEMON" == "hermes" ]
then
  echo "starting sendmail for $RUCIO_DAEMON"
  sendmail -bd
fi

echo "starting daemon with: $RUCIO_DAEMON $RUCIO_DAEMON_ARGS"
echo ""

if [ -z "$RUCIO_ENABLE_LOGS" ]; then
    eval "/usr/bin/rucio-$RUCIO_DAEMON $RUCIO_DAEMON_ARGS"
else
    eval "/usr/bin/rucio-$RUCIO_DAEMON $RUCIO_DAEMON_ARGS >> /var/log/rucio/daemon.log 2>> /var/log/rucio/error.log"
fi
