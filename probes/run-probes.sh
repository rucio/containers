#! /bin/bash

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

cd /probes/common

echo "Will run probes:"
echo $PROBES

# Accept probe names space separated and run each in turn
IFS=' ' read -r -a probes <<< $PROBES

for probe in "${probes[@]}"
do
    echo
    echo $probe
    ./${probe}
done

sleep 60