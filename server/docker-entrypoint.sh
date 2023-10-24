#!/bin/bash -e

j2 /tmp/00-mpm.conf.j2 > /etc/httpd/conf.modules.d/00-mpm.conf

echo "=================== /etc/httpd/conf.modules.d/00-mpm.conf ========================"
cat /etc/httpd/conf.modules.d/00-mpm.conf
echo ""

j2 /tmp/httpd.conf.j2 | sed '/^\s*$/d' > /etc/httpd/conf/httpd.conf

echo "=================== /etc/httpd/conf/httpd.conf ========================"
cat /etc/httpd/conf/httpd.conf
echo ""

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

(export RUCIO_PYTHON_PATH; j2 /tmp/rucio.conf.j2 | sed '/^\s*$/d' > /etc/httpd/conf.d/rucio.conf)

/usr/bin/memcached -u memcached -p 11211 -m 128 -c 1024 &

if [ ! -z "$RUCIO_METRICS_PORT" -a -z "$PROMETHEUS_MULTIPROC_DIR" -a -z "$prometheus_multiproc_dir" ]; then
    echo "Setting default PROMETHEUS_MULTIPROC_DIR to /tmp/prometheus"
    export PROMETHEUS_MULTIPROC_DIR=/tmp/prometheus
fi

echo "=================== /etc/httpd/conf.d/rucio.conf ========================"
cat /etc/httpd/conf.d/rucio.conf
echo ""

if [ -d "/patch" ]
then
    echo "Patches found. Trying to apply them"
    for patchfile in /patch/*
    do
        echo "Apply patch ${patchfile}"
        patch -p3 -d "$RUCIO_PYTHON_PATH" < $patchfile
    done
fi

pkill httpd || :
sleep 2
exec httpd -D FOREGROUND
