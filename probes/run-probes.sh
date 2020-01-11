#! /bin/bash

mkdir -p /opt/rucio/etc/

if [ -f /opt/rucio/etc/rucio.cfg ]; then
    echo "rucio.cfg already mounted."
else
    echo "rucio.cfg not found. will generate one."
    j2 /tmp/rucio.cfg.j2 | sed '/^\s*$/d' > /opt/rucio/etc/rucio.cfg
fi

if [ ! -z "$RUCIO_PRINT_CFG" ]; then
    echo "=================== /opt/rucio/etc/rucio.cfg ============================"
    cat /opt/rucio/etc/rucio.cfg
    echo ""
fi

cp /etc/jobber-config/dot-jobber.yaml /root/.jobber

echo "Starting Jobber"
/usr/local/libexec/jobbermaster &

sleep 5

echo
echo "============= Jobber log file ============="

tail -f /var/log/jobber-runs
