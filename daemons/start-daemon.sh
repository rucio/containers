#!/bin/sh

if [ ! -z "$USE_DAVIX_WITH_OPENSSL31" ]; then
    echo "=================== installing davix with openssl 3.1 ============================"
    rpm -i /tmp/rpms/openssl31-libs-3*.rpm
    rpm -U --force /tmp/rpms/davix-libs-0*.rpm
fi

if [ -f /opt/rucio/etc/rucio.cfg ]; then
    echo "rucio.cfg already mounted."
else
    echo "rucio.cfg not found. will generate one."
    python3 /usr/local/rucio/tools/merge_rucio_configs.py \
        -s /tmp/rucio.config.default.cfg $RUCIO_OVERRIDE_CONFIGS \
        --use-env \
        -d /opt/rucio/etc/rucio.cfg
fi

if [ ! -z "$RUCIO_PRINT_CFG" ]; then
    echo "=================== /opt/rucio/etc/rucio.cfg ============================"
    cat /opt/rucio/etc/rucio.cfg
    echo ""
fi

RUCIO_PYTHON_PATH=$(python3 -c "import os; import rucio; print(os.path.dirname(rucio.__file__))")

/usr/bin/memcached -u memcached -p 11211 -m 64 -c 1024 &

if [ "$RUCIO_DAEMON" == "hermes" ]
then
  echo "starting sendmail for $RUCIO_DAEMON"
  sendmail -bd
fi

if [ -d "/patch" ]
then
    echo "Patches found. Trying to apply them"
    for patchfile in /patch/*
    do
        echo "Apply patch ${patchfile}"
        patch -p3 -d "$RUCIO_PYTHON_PATH" < $patchfile
    done
fi

echo "starting daemon with: $RUCIO_DAEMON $RUCIO_DAEMON_ARGS"
echo ""

if [ -z "$RUCIO_ENABLE_LOGS" ]; then
    eval "exec /usr/bin/python3 /usr/local/bin/rucio-$RUCIO_DAEMON $RUCIO_DAEMON_ARGS"
else
    eval "exec /usr/bin/python3 /usr/local/bin/rucio-$RUCIO_DAEMON $RUCIO_DAEMON_ARGS >> /var/log/rucio/daemon.log 2>> /var/log/rucio/error.log"
fi
